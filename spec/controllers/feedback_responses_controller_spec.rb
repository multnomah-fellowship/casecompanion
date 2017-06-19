require 'rails_helper'

RSpec.describe FeedbackResponsesController, type: :controller do
  render_views

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
      expect { subject }.to change { FeedbackResponse.count }.by(1)
    end

    describe 'updating a previous feedback response' do
      let!(:previous_response) { FeedbackResponse.create(value: 'thumbs_down') }
      let(:params) { super().merge(previous_feedback_id: previous_response.id) }

      it { expect { subject }.not_to change { FeedbackResponse.count } }

      it 'updates the value as expected' do
        subject
        expect(previous_response.reload.value).to eq(type)
      end
    end
  end

  describe "PATCH #update" do
    let(:feedback_response) { FeedbackResponse.create(value: 'thumbs_down') }
    let(:params) do
      {
        id: feedback_response.id,
        feedback_response: {
          body: 'not enough Corgis',
        },
      }
    end

    subject { patch :update, params: params }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
      expect(feedback_response.reload.body).to eq(params[:feedback_response][:body])
    end
  end
end
