require 'mixpanel_middleware'

Rails.application.config.middleware.use(MixpanelMiddleware, ENV['MIXPANEL_TOKEN'])