app_name = if Rails.env.production?
             APP_DOMAIN =~ /staging/ ? 'MyAdvocate Staging' : 'MyAdvocate Production'
           else
             'MyAdvocate Development'
           end

Rails.application.config.slack_client =
  SlackClient.new(
    hook_url: ENV['SLACK_WEBHOOK_URL'],
    app_name: app_name
  )
