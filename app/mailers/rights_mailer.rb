# frozen_string_literal: true

class RightsMailer < ApplicationMailer
  layout 'email'
  helper :application
  helper :rights

  def vrn_receipt(court_case_subscription)
    @subscription = court_case_subscription

    mail(
      to: @subscription.email,
      subject: 'Victim Rights Notification Confirmation',
    )
  end
end
