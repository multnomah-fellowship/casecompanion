# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StyleguidesController, type: :controller do
  render_views

  describe 'GET #show' do
    subject { get :show }

    it 'renders' do
      subject
      expect(response).to be_success
    end
  end
end
