require 'rails_helper'

describe OffenderJurisdictionsController do
  render_views

  describe '#index' do
    let(:params) { {} }

    subject { get :index, params: params }

    describe 'with the dcj_search turned off' do
      it 'redirects to oregon search' do
        subject
        expect(response).to redirect_to(offender_jurisdiction_path(:oregon))
      end
    end

    describe 'with the dcj_search turned on' do
      around { |ex| enable_feature('dcj_search', ex) }

      it 'renders successfully' do
        subject
        expect(response).to be_success
      end
    end
  end

  describe '#show' do
    subject { get :show, params: params }

    %w[dcj oregon unknown].each do |jurisdiction|
      it "renders a search page for '#{jurisdiction}' jurisdiction" do
        get :show, params: { jurisdiction: jurisdiction }
        expect(response).to be_success
      end
    end

    describe 'with search by SID parameters (oregon)' do
      let(:params) { { offender: { sid: '1234' }, jurisdiction: 'oregon' } }

      it 'redirects to the offender show page' do
        subject
        expect(response).to redirect_to(offender_path(:oregon, params[:offender][:sid]))
      end
    end

    describe 'with search by name (oregon)' do
      let(:params) { { offender: { first_name: 'Tom', last_name: 'Dooner' }, jurisdiction: 'oregon' } }
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

    describe 'with search by DCJ SID / last name (dcj)' do
      let(:params) { { offender: { dcj_sid: 1234, dcj_last_name: 'Dooner' }, jurisdiction: 'dcj' } }
      let(:result) { { sid: 123456, jurisdiction: :dcj, first: 'Tom', last: 'Dooner', dob: '01/1991' } }

      before do
        allow_any_instance_of(DcjClient)
          .to receive(:offender_details)
          .and_return(result)
      end

      around { |ex| enable_feature('dcj_search', ex) }

      it 'renders the results' do
        subject
        expect(response.body).to include(result[:sid].to_s)
      end
    end
  end
end
