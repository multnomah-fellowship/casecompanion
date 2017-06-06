class DcjClient
  # TODO: replace this with the production one once the key is deployed
  URL_BASE = URI('https://uat.multco.us')

  class RequestError < StandardError; end

  def initialize(api_key: ENV['DCJ_BAXTER_API_KEY'])
    @api_key = api_key
  end

  # For now we have to search with the last name as well.
  #
  # TODO: Add caching, see if we can do a search without a last name.
  #
  # @return Hash? Information about the offender, if found.
  def offender_details(sid:, last_name:)
    fetch_offender_details(sid: sid, last_name: last_name)
  end

  private

  def fetch_offender_details(sid:, last_name:)
    Net::HTTP.start(URL_BASE.host, URL_BASE.port) do |http|
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
end
