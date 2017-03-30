class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_variables

  private

  def set_variables
    @phone_number = ENV['TWILIO_PHONE_NUMBER']
  end
end
