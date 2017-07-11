# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UtmAttribution, type: :model do
  describe '.new_from_params' do
    subject { described_class.new_from_params(ActionController::Parameters.new(params)) }

    context 'when no params are present' do
      let(:params) { {} }

      it 'creates an empty UtmAttribution' do
        expect(subject.utm_campaign).to be_nil
        expect(subject.utm_medium).to be_nil
      end
    end

    context 'when some params are present' do
      let(:params) { { 'utm_campaign' => 'foo-bar-baz' } }

      it 'creates a partially-filled UtmAttribution' do
        expect(subject.utm_campaign).to eq(params['utm_campaign'])
        expect(subject.utm_medium).to be_nil
      end
    end
  end
end
