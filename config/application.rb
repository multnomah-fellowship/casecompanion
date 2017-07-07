require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Raven.configure do |config|
  config.dsn = 'https://4868f5b344c44a8193359627f70d408b:9c295067a1bb4abc8a514b0ca84199fe@sentry.io/159399'
  config.environments = ['production']
  config.silence_ready = Rails.env.development? || Rails.env.test?
end

module MyAdvocate
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += [Rails.root.join('app/lib')]

    config.app_domain = ENV['APP_DOMAIN']

    config.mixpanel_token = ENV['MIXPANEL_TOKEN']

    config.action_view.default_form_builder = 'MyAdvocateFormBuilder'

    # Update the <input> tag for a field when it has errors based on the class
    # names that Materialize.css expects to see.
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      fragment = Nokogiri::HTML.fragment(html_tag)
      tag = fragment.children.first
      tag['class'] ||= ''
      tag['class'] = (tag['class'].split(/\s+/) | ['validate', 'invalid']).join(' ')
      tag['placeholder'] ||= '' # hack: this causes the label to auto-"activate"
      tag.to_s.html_safe
    end
  end
end
