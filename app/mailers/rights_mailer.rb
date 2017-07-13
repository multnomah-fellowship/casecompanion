# frozen_string_literal: true

class RightsMailer < ApplicationMailer
  # TODO: rename this to not start with "send_"
  def send_vrn_receipt(court_case_subscription)
    @subscription = court_case_subscription

    mail(
      to: @subscription.email,
      subject: 'Victim Rights Notification Confirmation',
    )
  end
end
