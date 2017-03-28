class NotificationsController < ApplicationController
  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.create(notification_params)

    client = FrontClient.new

    channel = client.list_channels.detect { |c| c.type == 'twilio' }
    client.send_message(channel.id, to: [@notification.phone_number], body: <<-MESSAGE.strip_heredoc)
      Hi #{@notification.first_name}, Libby has invited you to a new website to stay informed on your case.

      Feel free to visit https://myadvocate.TODO/special-link-here to see offender status and what notifications you can sign up for.

      Questions or concerns? Just reply here. We'll help you track down the right information.

      -Team MyAdvocate
    MESSAGE

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
