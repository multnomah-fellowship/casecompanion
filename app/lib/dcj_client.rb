class DcjClient
  URL_BASE = URI('https://www3.multco.us/Baxter')

  class RequestError < StandardError; end

  def initialize(api_key: ENV['DCJ_BAXTER_API_KEY'])
    @api_key = api_key
  end

  # For now we have to search with the last name as well.
  #
  # @return Hash? Information about the offender, if found.
  def offender_details(sid:, last_name: '')
    cached = OffenderSearchCache.find_by(offender_sid: sid)

    if cached
      offender_hash(cached.data)
    else
      unless last_name.present?
        raise 'DCJ API does not support SID-only search for uncached records'
      end

      data = fetch_offender_details(sid, last_name)

      return nil if data.nil?

      OffenderSearchCache
        .unscoped
        .where(offender_sid: sid)
        .first_or_create
        .tap { |record| record.assign_attributes(data: data, updated_at: Time.now) }
        .save

      offender_hash(data)
    end
  end

  private

  def fetch_offender_details(sid, last_name)
    Net::HTTP.start(URL_BASE.host, URL_BASE.port, use_ssl: true) do |http|
      request_uri = '/Baxter/api/polookup?' + URI.encode_www_form(
        key: @api_key,
        sid: sid,
        lastName: last_name
      )

      req = Net::HTTP::Get.new(request_uri)
      req['Accept'] = 'application/json'

      response = http.request(req)
      body = JSON.parse(response.body)

      unless response.code.to_i < 300
        raise RequestError.new("Baxter API Request Failed: #{body['Message']}")
      end

      body
    end
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
    }
  end
end
