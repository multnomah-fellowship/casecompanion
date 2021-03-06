# frozen_string_literal: true

class DcjClient
  URL_BASE = URI('https://www3.multco.us/Baxter')
  REQUEST_TIMEOUT = 29 # seconds

  class InvalidQueryError < StandardError; end
  class UncachedOffenderError < StandardError; end
  class RequestError < StandardError; end

  def initialize(api_key: ENV['DCJ_BAXTER_API_KEY'])
    @api_key = api_key
  end

  def search_for_offender(**kwargs)
    search_params = kwargs

    validate_search!(search_params)

    data = fetch_offender_details(search_params)

    return nil if data.nil?

    OffenderSearchCache
      .unscoped
      .where(offender_sid: data['SID'])
      .first_or_create
      .tap { |record| record.assign_attributes(data: data, updated_at: Time.now) }
      .save

    offender_hash(data)
  end

  # This can only return cached results because the API requires us to search
  # not only by SID but also with Birth date or Last Name.
  #
  # @return Hash? Information about the offender, if found.
  def offender_details(sid:)
    cached = OffenderSearchCache.find_by(offender_sid: sid)

    raise UncachedOffenderError, 'DCJ Lookup Error: Offender is uncached' unless cached

    offender_hash(cached.data)
  end

  private

  def validate_search!(search_params)
    if search_params[:last_name].blank?
      raise InvalidQueryError, 'Error searching: Offender Last Name is required'
    end

    return if search_params[:sid].present? || search_params[:dob].present?

    raise InvalidQueryError, 'Error searching: SID or DOB is required'
  end

  def fetch_offender_details(sid: '', last_name: '', dob: '')
    Timeout.timeout(REQUEST_TIMEOUT) do
      Net::HTTP.start(URL_BASE.host, URL_BASE.port, use_ssl: true) do |http|
        request_uri = '/Baxter/api/polookup?' + URI.encode_www_form(
          key: @api_key,
          sid: sid,
          lastName: last_name,
          dob: dob,
        )

        req = Net::HTTP::Get.new(request_uri)
        req['Accept'] = 'application/json'

        response = http.request(req)
        body = JSON.parse(response.body)

        return nil if response.code.to_i == 404

        if response.code.to_i >= 300
          raise RequestError, "Baxter API Request Failed: #{body['Message']}"
        end

        body
      end
    end
  rescue Timeout::Error
    raise RequestError, "Baxter API failed to respond within #{REQUEST_TIMEOUT} seconds"
  rescue => ex
    raise RequestError, "Unknown Baxter API Error: #{ex.message}"
  end

  def offender_hash(response_body)
    {
      jurisdiction: :dcj,
      first: response_body['OffenderFirstName'],
      last: response_body['OffenderLastName'],
      sid: response_body['SID'],
      dob: Date.parse(response_body['DOB']),
      po_first: response_body['POFirstName'],
      po_last: response_body['POLastName'],
      po_phone: response_body['POPhone'],
      supervision_expiration_date: response_body['ExpirationDate'],
      po_email: response_body['POEmail'],
    }
  end
end
