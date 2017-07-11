# frozen_string_literal: true

require 'rails_helper'

describe OffenderScraper do
  describe '.search_by_name' do
    let(:first_name) { 'Foo' }
    let(:last_name) { 'BarBaz' }
    let(:fake_result) do
      { sid: '1234', first: first_name, middle: '', last: last_name, dob: '01/1991' }
    end
    let(:searcher) { double(each_result: [fake_result]) }

    before do
      allow(OosMechanizer::Searcher)
        .to receive(:new)
        .and_return(searcher)
    end

    subject { OffenderScraper.search_by_name(first_name, last_name) }

    it 'searches with the right values' do
      expect(searcher)
        .to receive(:each_result)
        .with(first_name: first_name, last_name: last_name)
        .once

      subject
    end

    it 'returns results with a jurisdiction' do
      expect(subject[0][:jurisdiction]).to eq(:oregon)
    end

    context 'given a blank first name' do
      let(:first_name) { '' }

      it 'does not pass the argument into to OosMechanizer' do
        expect(searcher)
          .to receive(:each_result)
          .with(last_name: last_name)
          .and_return([])

        subject
      end
    end
  end

  describe '.offender_details' do
    # since stubbing all the mechanize stuff is going to be difficult, we can
    # just stub the scrap method to test the surrounding logic
    let(:fake_data) { { sid: '1234', name: 'Foo bar' } }

    before do
      OffenderSearchCache.unscoped.destroy_all # TODO: why no transactional fixtures?

      allow(OffenderScraper)
        .to receive(:fetch_offender_details)
        .and_return(fake_data)
    end

    context 'when never before scraped' do
      it 'returns the data from the scrape method' do
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(fake_data)
      end

      describe 'with a nonexistent (nil) record' do
        let(:fake_data) { nil }

        it 'returns nil without caching the data' do
          expect(OffenderScraper).to receive(:fetch_offender_details).exactly(2).times
          expect do
            expect(OffenderScraper.offender_details('NONEXISTENT_SID'))
              .to be_nil
            expect(OffenderScraper.offender_details('NONEXISTENT_SID'))
              .to be_nil
          end.not_to(change { OffenderSearchCache.count })
        end
      end
    end

    context 'with multiple scrapes' do
      it 'does not call .fetch_offender_details again' do
        expect(OffenderScraper).to receive(:fetch_offender_details).once

        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(fake_data)
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(fake_data)
      end
    end

    context 'with a purged scrape record' do
      let(:new_data) { fake_data.dup.tap { |h| h[:name] = 'Baz bar foo' } }

      before do
        OffenderSearchCache.purge_all!

        allow(OffenderScraper).to receive(:fetch_offender_details).and_return(new_data)
      end

      it 'returns the new data' do
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(new_data)
      end

      it 'calls fetch_offender_details once' do
        expect(OffenderScraper).to receive(:fetch_offender_details).once

        OffenderScraper.offender_details(fake_data[:sid])
        OffenderScraper.offender_details(fake_data[:sid])
      end
    end
  end
end
