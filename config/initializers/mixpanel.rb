# frozen_string_literal: true

require 'mixpanel_middleware'
require 'possibly_fake_request_ip_middleware'

Rails.application.config.middleware.use(MixpanelMiddleware, ENV['MIXPANEL_TOKEN'])
Rails.application.config.middleware.use(PossiblyFakeRequestIpMiddleware)
