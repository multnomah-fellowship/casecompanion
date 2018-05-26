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
    unless Rails.application.config.vrn_update_email_address.present?
      raise 'Error: Need to set VRN_UPDATE_EMAIL_ADDRESS'
    end

    @subscription = court_case_subscription

    remove_feedback_section!
    generate_and_attach_pdf(@subscription)

    mail(
      to: Rails.application.config.vrn_update_email_address,
      subject: "Victim Rights Updated: #{@subscription.first_name} #{@subscription.last_name}",
    )
  end

  def vrn_dda_update(court_case_subscription)
    @subscription = court_case_subscription
    return unless @subscription.dda_email.present?

    remove_feedback_section!
    generate_and_attach_pdf(@subscription)

    mail(
      to: @subscription.dda_email,
      subject: "VRN for Case DA##{@subscription.case_number}",
    )
  end

  private

  def generate_and_attach_pdf(subscription)
    pdf = RightsPdfGenerator.new(subscription).generate

    attachments[pdf.filename] = pdf.data
  end
end
