require 'rails_helper'

describe HomeController do
  render_views

  describe '#index' do
    let(:session) { {} }
    subject { get :index, session: session }

    describe 'when logged in as a victim advocate' do
      let(:user) { User.create!(email: 'foo@bar.com', password: 'foobar') }

      it 'renders links to send a notification' do
        session[:user_id] = user.id
        subject
        expect(response).to be_success
        expect(response.body).to include('Send Invitation')
      end
    end

    describe 'when logged out' do
      it 'renders a link to the offender search page' do
        subject
        expect(response).to be_success
        doc = Nokogiri::HTML(response.body)
        link = doc.css("a[href=\"/offenders\"]")
        expect(link).to be_present
      end
    end
  end
end
