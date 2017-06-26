require 'rails_helper'

RSpec.describe BetaSignupsController, type: :controller do
  render_views

  describe 'new' do
    subject { get :new }

    it 'renders successfully' do
      subject
      expect(response).to be_success
      expect(response.body).to include('Get the information')
    end
  end
end
