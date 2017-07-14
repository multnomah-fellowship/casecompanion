# frozen_string_literal: true

# This adds a `possibly_fake_request_ip` to the incoming request
#
# This is the *first* entry in X-Forwarded-For, which could be spoofed by the
# client.
#
# Contrast this with `request.ip` and `request.remote_ip` which return the
# *last* entry in that array.
class PossiblyFakeRequestIpMiddleware
  KEY = 'myadvocate.possibly_fake_request_ip'

  def initialize(app)
    @app = app
  end

  def call(env)
    env[KEY] = env.fetch('HTTP_X_FORWARDED_FOR', '').split(/,\s+/).first

    @app.call(env)
  end
end
