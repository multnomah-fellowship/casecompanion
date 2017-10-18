# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DigitalVrnsController, type: :controller do
  render_views

  describe '#index' do
    subject { get :index }

    context 'when not logged in' do
      it 'redirects' do
        subject
        expect(response).to be_redirect
      end
    end

    context 'as an admin' do
      include_context 'as an admin'

      it 'renders' do
        subject
        expect(response).to be_success
      end
    end
  end
end
