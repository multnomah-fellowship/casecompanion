# frozen_string_literal: true

app_name = if Rails.env.production?
             if ENV['APP_DOMAIN'].match?(/staging/)
               'MyAdvocate Staging'
             else
               'MyAdvocate Production'
             end
           else
             'MyAdvocate Development'
           end

Rails.application.config.slack_client =
  SlackClient.new(
    hook_url: ENV['SLACK_WEBHOOK_URL'],
    app_name: app_name,
  )
