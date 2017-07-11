# frozen_string_literal: true

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
    '15CR05613/01,MARI,POSSESS,METH,Inmate,Sentence,12/10/2015,-',
    '15CR05613/02,MARI,POSSESS,METH,Inmate,Sentence,12/10/2015,-',
    '15CR44118/01,MARI,FIREARM,-,FELON,POSSESS,Inmate,Sentence,12/10/2015,-',
    '15CR44118/03,MARI,DELIV,METH,NEAR,SCHOOL,Inmate,Sentence,12/10/2015,-',
  ],
  num_offenses: 4,
}.freeze

DCJ_OFFENDER = {
  jurisdiction: :dcj,
  first: 'John',
  last: 'Wilhite',
  sid: 20_130_142,
  dob: Date.parse('1980-01-01'),
  po_first: 'FrankThe',
  po_last: 'POPerson',
  po_phone: '503-555-1234 ext 12345',
}.freeze

RSpec.describe OffendersController do
  render_views

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

      describe 'when the offender is uncached' do
        before do
          allow_any_instance_of(DcjClient).to receive(:offender_details)
            .and_raise(DcjClient::UncachedOffenderError)
        end

        it 'redirects back to search' do
          subject
          expect(response).to redirect_to(/#{Regexp.escape(offender_jurisdiction_path(:dcj))}/)
        end
      end
    end
  end
end
