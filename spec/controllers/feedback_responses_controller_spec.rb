# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackResponsesController, type: :controller do
  render_views

  around { |ex| Rails.application.config.slack_client.disable_messages! { ex.run } }

  describe 'GET #create' do
    let(:type) { 'thumbs_up' }
    let(:params) { { type: type } }

    subject { get :create, params: params }

    FeedbackResponse.values.keys.each do |type|
      describe "for type=#{type}" do
        let(:type) { type }

        it 'returns http success' do
          subject
          expect(response).to have_http_status(:success)
        end
      end
    end

    it 'creates a feedback response' do
      expect { subject }.to(change { FeedbackResponse.count }.by(1))
    end

    it 'without a specific page defaults to nil' do
      subject
      expect(response.body).to include(I18n.t('footer.powered_by_html'))
      expect(FeedbackResponse.last.page).to be_nil
    end

    describe 'when giving feedback about the digital VRN receipt email' do
      let(:params) { super().merge(utm_campaign: 'vrn_receipt') }

      it 'creates a feedback response with that page and renders the email version' do
        subject
        expect(response.body).to have_tag('p', text: I18n.t('feedback_responses.header'))
        expect(FeedbackResponse.last.page).to eq('vrn_receipt')
      end
    end

    describe 'when giving feedback about a specific page' do
      let(:page) { 'foo-bar-baz' }
      let(:params) { super().merge(page: page) }

      it 'creates a feedback response with that page' do
        subject
        expect(FeedbackResponse.last.page).to eq(page)
      end
    end

    describe 'updating a previous feedback response' do
      let!(:previous_response) { FeedbackResponse.create(value: 'thumbs_down') }
      let(:params) { super().merge(previous_feedback_id: previous_response.id) }

      it { expect { subject }.not_to(change { FeedbackResponse.count }) }

      it 'updates the value as expected' do
        subject
        expect(previous_response.reload.value).to eq(type)
      end
    end
  end

  describe 'PATCH #update' do
    let(:feedback_response) { FeedbackResponse.create(value: 'thumbs_down', page: page) }
    let(:page) { '/' }
    let(:params) do
      {
        id: feedback_response.id,
        feedback_response: {
          body: 'not enough Corgis',
        },
      }
    end

    subject { patch :update, params: params }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:success)
      expect(feedback_response.reload.body).to eq(params[:feedback_response][:body])
    end

    context 'for a VRN confirmation email' do
      let(:page) { 'vrn-confirmation' }

      it 'returns success' do
        subject
        expect(response).to have_http_status(:success)
        expect(response.body).to have_tag('p', text: I18n.t('feedback_responses.header'))
      end
    end
  end
end
