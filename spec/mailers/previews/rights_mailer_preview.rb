# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/rights_mailer
class RightsMailerPreview < ActionMailer::Preview
  def send_vrn_receipt
    subscription = CourtCaseSubscription.new(
      first_name: 'Mary',
      last_name: 'Jones',
      email: 'mary@example.com',
      phone_number: '415-555-1234',
      case_number: '17CR1234',
      checked_rights: [
        Right.new(name: 'A-DDA to assert and enforce Victim Rights'),
        Right.new(name: 'B-Notified in advance of Critical Stage Proceedings'),
        Right.new(name: 'D-Notified in advance of Release Hrgs'),
        Right.new(name: 'K-Right to Restitution'),
      ],
    )

    RightsMailer.send_vrn_receipt(subscription)
  end
end
