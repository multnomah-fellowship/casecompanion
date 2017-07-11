class RightsMailer < ApplicationMailer
  def send_vrn_receipt(court_case_subscription)
    @subscription = court_case_subscription

    mail(
      to: @subscription.email,
      subject: 'Victim Rights Notification Confirmation',
    )
  end
end
