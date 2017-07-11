# frozen_string_literal: true

require 'rails_helper'

describe OffenderJurisdictionsController do
  render_views

  describe '#index' do
    let(:params) { {} }

    subject { get :index, params: params }

    it 'renders successfully' do
      subject
      expect(response).to be_success
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
  end

  describe '#search' do
    subject { post :search, params: params }

    describe 'with search by SID parameters (oregon)' do
      let(:params) { { offender: { sid: '1234' }, jurisdiction: 'oregon' } }

      it 'redirects to the offender show page' do
        subject
        expect(response).to redirect_to(offender_path(:oregon, params[:offender][:sid]))
      end
    end

    describe 'with search by name (oregon)' do
      let(:params) do
        { offender: { first_name: 'Tom', last_name: 'Dooner' }, jurisdiction: 'oregon' }
      end
      let(:results) { [{ sid: 123_456, jurisdiction: :oregon, first: 'Tom', last: 'Dooner' }] }

      before do
        allow(OffenderScraper).to receive(:search_by_name).and_return(results)
      end

      it 'renders the results' do
        subject
        expect(response.body).to include(results[0][:sid].to_s)
      end

      it 'tracks a mixpanel event' do
        expect { subject }
          .to track_mixpanel_event('search', include(jurisdiction: 'oregon'))
      end

      describe 'when there are no results' do
        let(:results) { [] }

        it 'gives an error' do
          subject
          expect(response.body).to include("We couldn't find")
        end
      end
    end

    describe 'with search by DCJ date of birth / last name (dcj)' do
      let(:params) do
        {
          offender: {
            dob: { month: '01', day: '01', year: '1991' },
            last_name: 'Dooner',
          },
          jurisdiction: 'dcj',
        }
      end

      it 'renders the results' do
        subject
        expect(response.body).to include('20130142')
      end
    end

    describe 'with search for "unknown" jurisdiction' do
      let(:params) do
        {
          jurisdiction: :unknown,
          offender: {
            first_name: 'John',
            last_name: 'Doe',
            dob: { month: '01', day: '01', year: '1991' },
          },
        }
      end

      let(:dcj_result) do
        { sid: 123_456, jurisdiction: :dcj, first: 'Tom', last: 'Dooner', dob: '01/1991' }
      end

      let(:oregon_results) do
        [{ sid: 4_445_555, jurisdiction: :oregon, first: 'Tom', last: 'Dooner' }]
      end

      before do
        allow_any_instance_of(DcjClient)
          .to receive(:search_for_offender)
          .and_return(dcj_result)

        allow(OffenderScraper)
          .to receive(:search_by_name).and_return(oregon_results)
      end

      it 'renders the results' do
        subject
        expect(response.body).to include(dcj_result[:sid].to_s)
        expect(response.body).to include(oregon_results[0][:sid].to_s)
      end
    end
  end
end
