require 'spec_helper'

describe DcjClient do
  let(:offender_hash) do
    {
      'OffenderFirstName' => 'John',
      'OffenderLastName' => 'Wilhite',
      'SID' => 20130142,
      'DOB' => '1977-11-07T00:00:00',
      'POFirstName' => 'Frank',
      'POLastName' => 'SomeRandomName',
      'POPhone' => '503-555-1234 ext 12345',
    }
  end

  before do
    OffenderSearchCache.unscoped.destroy_all

    allow_any_instance_of(DcjClient)
      .to receive(:fetch_offender_details)
      .and_return(offender_hash)
  end

  describe '#offender_details' do
    let(:client) { described_class.new(api_key: '123') }

    describe 'the first search for an offender' do
      subject { client.offender_details(last_name: 'foo', sid: 1234) }

      it 'returns a hash of data in the standard format' do
        expect(subject[:first]).to eq(offender_hash['OffenderFirstName'])
        expect(subject[:last]).to eq(offender_hash['OffenderLastName'])
        expect(subject[:sid]).to eq(offender_hash['SID'])
      end
    end

    describe 'searching again for a cached offender' do
      let(:search_sid) { 1234 }

      it 'allows searching without last name a subsequent time' do
        first = client.offender_details(last_name: 'foo', sid: search_sid)
        second = client.offender_details(sid: search_sid)

        expect(first).to eq(second)
      end

      it 'only calls the fetch method once' do
        expect_any_instance_of(DcjClient)
          .to receive(:fetch_offender_details)
          .once

        client.offender_details(last_name: 'foo', sid: search_sid)
        client.offender_details(sid: search_sid)
      end
    end
  end
end
