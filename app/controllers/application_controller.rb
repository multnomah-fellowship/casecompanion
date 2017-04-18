class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_variables
  before_action :clear_notification_id
  before_action :set_raven_context

  private

  def set_variables
    @phone_number = ENV['TWILIO_PHONE_NUMBER']
    @mixpanel_token = Rails.application.config.mixpanel_token
  end

  # Clear any residual notification_id's that are in sessions, since we're not
  # using the magic links anymore.
  def clear_notification_id
    session.delete(:notification_id)
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
