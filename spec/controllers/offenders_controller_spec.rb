require 'spec_helper'

RSpec.describe 'OffendersController' do
  describe 'GET /search' do
    subject { get :search }

    it 'renders successfully' do
      subject
      expect(response).to be_success
    end
  end
end
