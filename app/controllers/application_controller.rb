class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_variables
  before_action :set_raven_context
  before_action :set_current_user

  private

  def set_variables
    @phone_number = ENV['TWILIO_PHONE_NUMBER']
    @mixpanel_token = Rails.application.config.mixpanel_token
  end

  def set_current_user
    @current_user ||= if session[:user_id]
                        User.find(session[:user_id])
                      end
  end

  def set_raven_context
    Raven.user_context(
      distinct_id: session[:distinct_id]
    )

    Raven.extra_context(
      url: request.url
    )
  end
end
