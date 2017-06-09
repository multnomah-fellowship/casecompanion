# TODO: remove this whole thing
class NotificationsController < ApplicationController
  def new
    @notification = Notification.new
  end

  def show
    redirect_to offender_path(:oregon, params[:o])
  end

  def create
    @notification = Notification.create(notification_params)

    client = FrontClient.new

    session_link =
      "https://#{Rails.application.config.app_domain}/n/#{@notification.id}?o=#{@notification.offender_sid}"

    channel = client.list_channels.detect { |c| c.type == 'twilio' }
    client.send_message(channel.id, to: [@notification.phone_number], body: <<-MESSAGE.strip_heredoc)
      Hi #{@notification.first_name}, as I mentioned there's a tool we have that allows you to look up offender info and answer some frequently asked questions for you.

      Feel free to visit #{session_link} to see offender status and what notifications you can sign up for.

      Questions or concerns? Just reply here. I'll help you track down the right information.

      -Pam
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
