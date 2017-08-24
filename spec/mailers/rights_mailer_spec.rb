# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RightsMailer, type: :mailer do
  include_context 'with fake advocate'

  let(:subscription) do
    CourtCaseSubscription.new(
      first_name: 'Mary',
      last_name: 'Jones',
      email: 'mary@example.com',
      phone_number: '415-555-1234',
      case_number: '17CR1234',
      advocate_email: FAKE_ADVOCATE_EMAIL,
      checked_rights: [
        Right.new(name: 'A-DDA to assert and enforce Victim Rights'),
        Right.new(name: 'B-Notified in advance of Critical Stage Proceedings'),
        Right.new(name: 'D-Notified in advance of Release Hrgs'),
        Right.new(name: 'K-Right to Restitution'),
      ],
    )
  end

  describe '#vrn_receipt' do
    subject { described_class.vrn_receipt(subscription) }

    it 'renders' do
      expect(subject.subject).to include('Victim Rights Notification')
      expect(subject.to).to include(subscription.email)
      expect(subject.body.encoded).to be_present
    end
  end

  describe '#vrn_advocate_update' do
    subject { described_class.vrn_advocate_update(subscription) }

    it 'renders' do
      expect(subject.subject).to include('Victim Rights Updated')
      expect(subject.body.encoded).to include(subscription.email)
    end
  end
end
