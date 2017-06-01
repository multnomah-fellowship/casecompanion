require 'rails_helper'

describe HomeController do
  render_views

  describe '#splash' do
    let(:session) { {} }
    subject { get :splash, session: session }

    describe 'when logged in as a victim' do
      let(:user) { User.create!(email: 'foo@bar.com', password: 'foobar') }

      it 'redirects to /home' do
        session[:user_id] = user.id
        subject
        expect(response).to redirect_to(home_path)
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

  describe '#sandbox' do
    subject { get :sandbox }

    it 'renders successfully' do
      subject
      expect(response).to be_success
    end
  end
end
