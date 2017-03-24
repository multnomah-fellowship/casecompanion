class NotificationsController < ApplicationController
  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.create(notification_params)

    if @notification.persisted?
      flash[:info] = 'Notification sent!'
      redirect_to root_path
    else
      flash[:error] = "Could not create notification: #{@notification.errors.full_messages.join(', ')}"
      render :new
    end
  end

  private

  def notification_params
    params.fetch(:notification, {})
      .permit(:first_name, :offender_sid, :phone_number)
  end
end
