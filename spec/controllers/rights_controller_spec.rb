# frozen_string_literal: true

require 'rails_helper'

describe RightsController, type: :controller do
  render_views

  describe '#index' do
    it 'redirects to the first right' do
      get :index
      expect(response)
        .to redirect_to(right_path(RightsFlow::PAGES[0]))
    end
  end

  describe '#preview' do
    subject { get :preview, format: 'pdf' }

    it 'renders' do
      subject

      expect(response).to be_success
      expect(response.headers['Content-Type']).to include('application/pdf')
    end
  end
end
