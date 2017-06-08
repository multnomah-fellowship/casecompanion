require 'rails_helper'

OFFENDER_FIXTURE = {
  jurisdiction: :oregon,
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

DCJ_OFFENDER = {
  jurisdiction: :dcj,
  first: 'John',
  last: 'Wilhite',
  sid: 20130142,
  dob: Date.parse('1980-01-01'),
  po_first: 'FrankThe',
  po_last: 'POPerson',
  po_phone: '503-555-1234 ext 12345',
}

RSpec.describe OffendersController do
  render_views

  describe 'GET /index' do
    let(:params) { {} }

    subject { get :index, params: params }

    it 'renders successfully' do
      subject
      expect(response).to be_success
    end

    describe 'with search by SID parameters' do
      let(:params) { { offender: { sid: '1234' } } }

      it 'redirects to the offender show page' do
        subject
        expect(response).to redirect_to(offender_offenders_path(:oregon, params[:offender][:sid]))
      end
    end

    describe 'with search by name' do
      let(:params) { { offender: { first_name: 'Tom', last_name: 'Dooner' } } }
      let(:results) { [{ sid: 123456, jurisdiction: :oregon, first: 'Tom', last: 'Dooner' }] }

      before do
        allow(OffenderScraper).to receive(:search_by_name).and_return(results)
      end

      it 'renders the results' do
        subject
        expect(response.body).to include(results[0][:sid].to_s)
      end

      describe 'when there are no results' do
        let(:results) { [] }

        it 'gives an error' do
          subject
          expect(response.body).to include("We couldn't find that offender.")
        end
      end
    end
  end

  describe 'GET /show' do
    before do
      allow(OffenderScraper).to receive(:offender_details)
        .with(OFFENDER_FIXTURE[:sid])
        .and_return(OFFENDER_FIXTURE)

      allow_any_instance_of(DcjClient).to receive(:offender_details)
        .with(sid: DCJ_OFFENDER[:sid].to_s)
        .and_return(DCJ_OFFENDER)
    end

    subject { get :show, params: params }

    describe 'with an offender from oregon jurisdiction' do
      let(:params) { { id: OFFENDER_FIXTURE[:sid], jurisdiction: :oregon } }

      it 'shows the offender' do
        subject
        expect(response.body).to include(OFFENDER_FIXTURE[:sid])
      end

      it 'gives a contextual vine link' do
        subject
        expect(response).to be_success
        sid = OFFENDER_FIXTURE[:sid]

        link = Nokogiri::HTML(response.body).css("a[href*=\"#{sid}\"]:contains(\"VINE\")")
        expect(link).to be_present
      end
    end

    describe 'with an offender from DCJ jurisdiction' do
      let(:params) { { id: DCJ_OFFENDER[:sid], jurisdiction: 'dcj' } }

      it 'shows the offender' do
        subject
        expect(response.body).to include(DCJ_OFFENDER[:sid].to_s)
      end
    end
  end
end
