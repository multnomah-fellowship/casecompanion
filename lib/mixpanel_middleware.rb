# This is a maybe-too-clever class to attempt to synchronize the distinct_id on
# server-sent events to match the client-side event.
#
# This is done by parsing the value of the `mp_*_mixpanel` cookie and storing
# its value in the `env` which is available in controllers via `request.env`.
class MixpanelMiddleware
  DISTINCT_ID = 'myadvocate.mixpanel_distinct_id'.freeze

  def initialize(app, mixpanel_token)
    @app = app
    @mixpanel_token = mixpanel_token
  end

  def call(env)
    request = Rack::Request.new(env)
    distinct_id = nil

    begin
      mixpanel_cookie = request.cookies["mp_#{@mixpanel_token}_mixpanel"]
      if mixpanel_cookie
        distinct_id = JSON.parse(mixpanel_cookie)['distinct_id']
      end
    rescue => ex
      Raven.capture_exception(ex)
      raise ex if Rails.env.development?
    ensure
      env[DISTINCT_ID] = distinct_id
    end

    @app.call(env)
  end
end

