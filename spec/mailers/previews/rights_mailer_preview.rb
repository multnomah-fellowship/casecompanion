# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/rights_mailer
class RightsMailerPreview < ActionMailer::Preview
  def vrn_receipt
    RightsMailer.vrn_receipt(sample_subscription)
  end

  def vrn_advocate_update
    RightsMailer.vrn_advocate_update(sample_subscription)
  end

  private

  def sample_subscription
    CourtCaseSubscription.new(
      first_name: 'Mary',
      last_name: 'Jones',
      email: 'mary@example.com',
      phone_number: '415-555-1234',
      case_number: '17CR1234',
      advocate_email: AdvocateList.name_and_emails.first.last,
      checked_rights: [
        Right.new(name: 'A-DDA to assert and enforce Victim Rights'),
        Right.new(name: 'B-Notified in advance of Critical Stage Proceedings'),
        Right.new(name: 'D-Notified in advance of Release Hrgs'),
        Right.new(name: 'K-Right to Restitution'),
      ],
    )
  end
end
