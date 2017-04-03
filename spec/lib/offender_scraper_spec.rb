require 'rails_helper'

describe OffenderScraper do
  describe '.offender_details' do
    # since stubbing all the mechanize stuff is going to be difficult, we can
    # just stub the scrap method to test the surrounding logic
    let(:fake_data) { { sid: '1234', name: 'Foo bar' } }

    before do
      allow(OffenderScraper).to receive(:scrape!).and_return(fake_data)
    end

    context 'when never before scraped' do
      it 'returns the data from the scrape method' do
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(fake_data)
      end
    end

    context 'with multiple scrapes' do
      it 'does not call .scrape! again' do
        expect(OffenderScraper).to receive(:scrape!).once
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(fake_data)
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(fake_data)
      end
    end

    context 'with a purged scrape record' do
      let(:new_data) { fake_data.dup.tap { |h| h[:name] = 'Baz bar foo' } }

      before do
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(fake_data)
        OffenderSearchCache.purge_all!
        allow(OffenderScraper).to receive(:scrape!).and_return(new_data)
      end

      it 'returns the new data' do
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(new_data)
      end

      it 'calls scrape! once' do
        expect(OffenderScraper).to receive(:scrape!).once

        OffenderScraper.offender_details(fake_data[:sid])
        OffenderScraper.offender_details(fake_data[:sid])
      end
    end
  end
end
