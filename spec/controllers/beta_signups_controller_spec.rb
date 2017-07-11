# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BetaSignupsController, type: :controller do
  render_views

  describe '#new' do
    subject { get :new }

    it 'renders successfully' do
      subject
      expect(response).to be_success
      expect(response.body).to include('Get the information')
    end
  end

  describe '#create' do
    around { |ex| Rails.application.config.slack_client.disable_messages!(&ex) }

    subject { post :create, params: params }

    let(:params) do
      {
        beta_signup: {
          email: 'foo-bar-baz',
          utm_attribution_attributes: {
            utm_source: 'source-foo',
            utm_campaign: 'campaign-1234',
          },
        },
      }
    end

    it 'creates a beta signup with attribution' do
      expect { subject }.to change { BetaSignup.count }.by(1)

      created = BetaSignup.last
      expect(created.utm_attribution.utm_source).to eq('source-foo')
      expect(created.utm_attribution.utm_campaign).to eq('campaign-1234')
    end

    it 'renders successfully' do
      subject
      expect(response).to be_success
      expect(response.body).to include('Great!')
    end
  end
end
