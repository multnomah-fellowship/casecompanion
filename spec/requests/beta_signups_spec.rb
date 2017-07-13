# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BetaSignup' do
  describe 'with a blank email' do
    it 'does not persist the BetaSignup and gives an error' do
      post '/beta', params: { email: '' }
      expect(response).to be_success
      expect(response.body).to include('Email can\'t be blank')
    end
  end
end
