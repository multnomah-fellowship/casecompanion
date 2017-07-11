# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RightsMailer, type: :mailer do
  describe '#send_vrn_receipt' do
    let(:subscription) do
      CourtCaseSubscription.new(
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
    end

    subject { described_class.send_vrn_receipt(subscription) }

    it 'renders' do
      expect(subject.subject).to include('Victim Rights Notification')
      expect(subject.to).to include(subscription.email)
      expect(subject.body.encoded).to be_present
    end
  end
end
