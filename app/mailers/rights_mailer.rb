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

    pdf_name = %W[
      VRN
      DA##{@subscription.case_number}
      #{@subscription.first_name}
      #{@subscription.last_name}
    ].join('-') + '.pdf'

    attachments[pdf_name] = RightsPdfGenerator.new(@subscription).generate.data

    mail(
      to: Rails.application.config.vrn_update_email_address,
      subject: "Victim Rights Updated: #{@subscription.first_name} #{@subscription.last_name}",
    )
  end
end
