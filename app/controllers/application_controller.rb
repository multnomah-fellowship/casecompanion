# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_variables
  before_action :set_raven_context
  before_action :set_current_user
  before_action :set_mixpanel

  private

  def set_variables
    @mixpanel_token = Rails.application.config.mixpanel_token
  end

  def set_current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def set_raven_context
    Raven.user_context(
      distinct_id: session[:distinct_id],
    )

    Raven.extra_context(
      url: request.url,
    )
  end

  def set_mixpanel
    # This is to help me trace down the incorrect cities in the Mixpanel
    # server-side events on heroku
    if helpers.feature_enabled?('log_request_ips')
      Rails.logger.info(JSON.generate(
        'request.ip' => request.ip,
        'request.remote_ip' => request.remote_ip,
        'request.remote_addr' => request.remote_addr,
        'x-forwarded-for' => request.headers['X-Forwarded-For'],
      ))
    end

    @mixpanel ||= MixpanelTrackerWrapper.from_request(request)
  end
end
