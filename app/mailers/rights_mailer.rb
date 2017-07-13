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

  def vrn_advocate_update(court_case_subscription)
    @subscription = court_case_subscription

    remove_feedback_section!

    mail(
      to: 'tdooner@codeforamerica.org',
      subject: "Victim Rights Updated: #{@subscription.first_name} #{@subscription.last_name}",
    )
  end
end
