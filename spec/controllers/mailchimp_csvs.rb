# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailchimpCsvsController do
  let(:csv_id) { MailchimpCsvGenerator::CSVS.keys.sample }
  let(:session) { {} }

  subject do
    get :show, params: { id: csv_id }, session: session
  end

  context 'when logged out' do
    it 'redirects home' do
      subject
      expect(response).to be_redirect
    end
  end

  context 'when logged in as an admin user' do
    before do
      allow(LocalCrimesInPostgres)
        .to receive(:new)
        .and_return(nil)
      allow_any_instance_of(MailchimpCsvGenerator)
        .to receive(:generate_by_name)

      session[:user_id] = User.create(
        email: 'tdooner@codeforamerica.org',
        password: 'password',
        is_admin: true,
      ).id
    end

    it 'renders the CSV' do
      subject
      expect(response).to be_success
    end
  end
end
