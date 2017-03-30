require 'rails_helper'

OFFENDER_FIXTURE = {
  sid: '11273355',
  age: '41',
  gender: 'Female',
  height: '5\' 06',
  weight: '140 lbs',
  dob: '10/1975',
  race: 'White Or European Origin',
  hair: 'Blond',
  eyes: 'Blue',
  caseload_number: '01617',
  caseload_name: 'Firestone, Abbie',
  location: '',
  status: 'Inmate',
  admission_date: '12/10/2015',
  earliest_release_date: '05/10/2017',
  offenses: [
    "15CR05613/01,MARI,POSSESS,METH,Inmate,Sentence,12/10/2015,-",
    "15CR05613/02,MARI,POSSESS,METH,Inmate,Sentence,12/10/2015,-",
    "15CR44118/01,MARI,FIREARM,-,FELON,POSSESS,Inmate,Sentence,12/10/2015,-",
    "15CR44118/03,MARI,DELIV,METH,NEAR,SCHOOL,Inmate,Sentence,12/10/2015,-"
  ],
  num_offenses: 4,
}

RSpec.describe OffendersController do
  render_views

  describe 'GET /index' do
    subject { get :index }

    it 'renders successfully' do
      subject
      expect(response).to be_success
    end
  end

  describe 'POST /search' do
    let(:params) { { offender: { sid: '1234' } } }

    subject { post :search, params: params }

    it 'redirects to the offender show page' do
      subject
      expect(response).to redirect_to(offender_path(params[:offender][:sid]))
    end
  end

  describe 'GET /show' do
    before do
      allow(OffenderScraper).to receive(:offender_details)
        .with(OFFENDER_FIXTURE[:sid])
        .and_return(OFFENDER_FIXTURE)
    end

    subject { get :show, params: { id: OFFENDER_FIXTURE[:sid] } }

    it 'shows the offender' do
      subject
      expect(response.body).to include(OFFENDER_FIXTURE[:sid])
    end
  end
end
