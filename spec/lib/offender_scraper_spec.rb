require 'rails_helper'

describe OffenderScraper do
  describe '.offender_details' do
    # since stubbing all the mechanize stuff is going to be difficult, we can
    # just stub the scrap method to test the surrounding logic
    let(:fake_data) { { sid: '1234', name: 'Foo bar' } }

    before do
      allow(OffenderScraper).to receive(:fetch_offender_details).and_return(fake_data)
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
          end.not_to change { OffenderSearchCache.count }
        end
      end
    end

    context 'with multiple scrapes' do
      it 'does not call .process_page again' do
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
