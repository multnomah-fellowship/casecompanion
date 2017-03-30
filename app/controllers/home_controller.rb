class HomeController < ApplicationController
  def index
    @notification = Notification.find(session[:notification_id]) if session[:notification_id]
  end

  def notification_systems
  end
end
