require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyAdvocate
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += [Rails.root.join('app/lib')]

    config.app_domain = ENV['APP_DOMAIN']

    config.mixpanel_token = ENV['MIXPANEL_TOKEN']
  end
end
