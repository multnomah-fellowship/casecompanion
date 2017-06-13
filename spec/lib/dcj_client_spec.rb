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

  describe '#search_for_offender' do
    let(:client) { described_class.new(api_key: '123') }
    let(:query) { {} }

    subject { client.search_for_offender(query) }

    describe 'with invalid queries' do
      describe 'with a query of only SID' do
        let(:query) { { sid: 1234 } }
        it { expect { subject }.to raise_error(DcjClient::InvalidQueryError) }
      end

      describe 'with a bad DOB' do
        let(:query) { { sid: 1234, dob: '1234' } }
        it { expect { subject }.to raise_error(DcjClient::InvalidQueryError) }
      end
    end

    describe 'with a valid query' do
      let(:query) { { sid: 1234, last_name: 'foo' } }

      it 'caches results' do
        expect { subject }.to change { OffenderSearchCache.count }.by(1)
      end
    end
  end

  describe '#offender_details' do
    let(:client) { described_class.new(api_key: '123') }
    let(:search_sid) { offender_hash['SID'] }

    subject { client.offender_details(sid: search_sid) }

    describe 'when the offender has not been searched for yet' do
      it 'raises an error' do
        expect { subject }.to raise_error(DcjClient::UncachedOffenderError)
      end
    end

    describe 'for an offender who has been searched for' do
      before do
        client.search_for_offender(sid: search_sid, last_name: 'willy')
      end

      it 'returns a hash of data in the standard format' do
        expect(subject[:first]).to eq(offender_hash['OffenderFirstName'])
        expect(subject[:last]).to eq(offender_hash['OffenderLastName'])
        expect(subject[:sid]).to eq(offender_hash['SID'])
      end
    end
  end
end
