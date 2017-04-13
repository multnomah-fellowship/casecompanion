require 'rails_helper'

describe OffenderScraper do
  def mechanize_page(fixture = nil)
    fixture_path = File.expand_path(Rails.root.join('spec', 'fixtures', fixture)) if fixture
    Mechanize::Page.new(
      URI('http://example.com/'),
      nil,
      fixture ? File.read(fixture_path) : '<html></html>',
      200,
      Mechanize.new
    )
  end

  describe '.offender_details' do
    # since stubbing all the mechanize stuff is going to be difficult, we can
    # just stub the scrap method to test the surrounding logic
    let(:fake_data) { { sid: '1234', name: 'Foo bar' } }

    before do
      allow(OffenderScraper).to receive(:fetch_results_page).and_return(mechanize_page)
      allow(OffenderScraper).to receive(:process_page).and_return(fake_data)
    end

    context 'with a page with an unknown location' do
      before do
        allow(OffenderScraper).to receive(:fetch_results_page).and_return(mechanize_page('offender_with_no_location.html'))
        allow(OffenderScraper).to receive(:process_page).and_call_original
      end

      it 'returns the location string' do
        expect(OffenderScraper.offender_details('1234')).to include(location: match(/Marion County/))
      end
    end

    context 'when never before scraped' do
      it 'returns the data from the scrape method' do
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(fake_data)
      end

      describe 'with a nonexistent (nil) record' do
        let(:fake_data) { nil }

        it 'returns nil without caching the data' do
          expect(OffenderScraper).to receive(:process_page).exactly(2).times
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
        expect(OffenderScraper).to receive(:process_page).once
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
        allow(OffenderScraper).to receive(:process_page).and_return(new_data)
      end

      it 'returns the new data' do
        expect(OffenderScraper.offender_details(fake_data[:sid]))
          .to eq(new_data)
      end

      it 'calls process_page once' do
        expect(OffenderScraper).to receive(:process_page).once

        OffenderScraper.offender_details(fake_data[:sid])
        OffenderScraper.offender_details(fake_data[:sid])
      end
    end
  end
end
