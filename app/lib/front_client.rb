require 'net/http'
require 'ostruct'
require 'json'
require 'uri'

class FrontClient
  BASE_URL = URI('https://api2.frontapp.com')

  # API Objects
  class Channel < OpenStruct; end
  class Message < OpenStruct; end

  # API Errors
  class NoTokenProvidedError < StandardError; end
  class RequiredArgumentMissingError < StandardError; end
  class UnexpectedStatusError < StandardError; end

  def initialize(web_token: ENV['FRONT_WEB_TOKEN'])
    raise NoTokenProvidedError if web_token.blank?

    @web_token = web_token
  end

  def list_channels
    response = authenticated_request('/channels')

    process_response(response, Channel)
  end

  def send_message(channel_id, body)
    if channel_id.blank?
      raise RequiredArgumentMissingError, "Missing channel_id, got: #{channel_id.inspect}"
    end

    response = authenticated_request("/channels/#{channel_id}/messages", klass: Net::HTTP::Post) do |request|
      request['Content-Type'] = 'application/json'
      request.body = JSON.generate(body)
    end

    process_response_raw(response)['conversation_reference']
  end

  private

  def authenticated_request(path, klass: Net::HTTP::Get)
    Net::HTTP.start(BASE_URL.host, BASE_URL.port, use_ssl: true) do |http|
      request = klass.new(path)
      request['Accept'] = 'application/json'
      request['Authorization'] = "Bearer #{@web_token}"
      yield request if block_given?

      http.request request
    end
  end

  def process_response(response, item_klass)
    if response.code.to_i >= 300
      raise UnexpectedStatusError, "Front API Returned #{response.code} - #{response.body}"
    end

    parsed = JSON.parse(response.body)

    # TODO: handle errors
    if parsed['_results']
      # response is an array of objects
      parsed['_results'].map do |result|
        result.delete('_links')

        item_klass.new(result)
      end
    elsif parsed['id']
      # response is a single object
      result.delete('_links')

      item_klass.new(result)
    end
  end

  def process_response_raw(response)
    if response.code.to_i >= 300
      raise UnexpectedStatusError, "Front API Returned #{response.code} - #{response.body}"
    end

    JSON.parse(response.body)
  end
end
