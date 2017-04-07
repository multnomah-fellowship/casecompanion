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

    describe 'with a notification_id in the session' do
      let(:offender_sid) { (Random.rand * 100_000_000).floor }
      let(:notification) do
        Notification.create!(
          first_name: 'Tom',
          offender_sid: offender_sid,
          phone_number: '123-456-7890'
        )
      end

      it 'renders a link directly to that offender show page' do
        session[:notification_id] = notification.id
        subject
        expect(response).to be_success
        doc = Nokogiri::HTML(response.body)
        link = doc.css("a[href=\"/offenders/#{offender_sid}\"]")
        expect(link).to be_present
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

  describe '#notification_systems' do
    subject { get :notification_systems }

    it 'renders' do
      subject
      expect(response).to be_success
    end

    describe 'when given a offender_id' do
      let(:sid) { '123456' }
      subject { get :notification_systems, params: { offender_id: sid } }

      it 'gives a contextual vine link' do
        subject
        expect(response).to be_success

        link = Nokogiri::HTML(response.body).css("a#vine-link[href*=\"#{sid}\"]")
        expect(link).to be_present
      end
    end
  end
end
