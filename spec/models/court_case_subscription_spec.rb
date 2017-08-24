# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourtCaseSubscription do
  describe '#checked_right?' do
    let(:user) { User.create(email: 'foo@bar.com', password: 'foobar') }
    let(:subscription) { CourtCaseSubscription.create(user: user, case_number: '17CR1234') }
    let(:checked_rights) { Right::RIGHTS.keys.sample(2) }
    let(:unchecked_rights) { Right::RIGHTS.keys - checked_rights }

    before do
      checked_rights.each do |flag|
        Right.create(court_case_subscription: subscription, name: Right::RIGHTS[flag])
      end
    end

    subject { subscription.checked_right?(right_to_check) }

    describe 'for a checked right' do
      let(:right_to_check) { checked_rights.sample }
      it { is_expected.to be true }
    end

    describe 'for an unchecked right' do
      let(:right_to_check) { unchecked_rights.sample }
      it { is_expected.to be false }
    end
  end

  describe '#rights_hash' do
    let(:user) { User.create(email: 'foo@bar.com', password: 'foobar') }
    let(:subscription) { CourtCaseSubscription.create(user: user, case_number: '17CR1234') }
    let(:checked_rights) { Right::NAMES.sample(2) }

    before do
      checked_rights.each do |name|
        Right.create(court_case_subscription: subscription, name: name)
      end
    end

    subject { subscription.rights_hash }

    it 'returns a hash of rights' do
      expect(subject).to be_a(Hash)
      expect(subject.length).to eq(Right::NAMES.length)
    end

    it 'has true values for checked rights' do
      expect(subject.slice(*checked_rights).length).to eq(checked_rights.length)
      expect(subject.slice(*checked_rights).values).to be_all
    end

    it 'has false values for the other rights' do
      expect(subject.without(*checked_rights).length)
        .to eq(Right::NAMES.length - checked_rights.length)
      expect(subject.without(*checked_rights).values).to be_none
    end
  end
end
