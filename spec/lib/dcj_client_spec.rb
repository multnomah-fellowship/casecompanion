require 'rails_helper'

describe DcjClient do
  before do
    OffenderSearchCache.unscoped.destroy_all
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
    end

    describe 'with a valid query' do
      let(:query) { { sid: 1234, last_name: 'foo', dob: Date.new(1991, 11, 1) } }

      it 'caches results' do
        expect { subject }.to change { OffenderSearchCache.count }.by(1)
      end

      it 'searches for the right things' do
        expect(client)
          .to receive(:fetch_offender_details)
          .with(hash_including(
            dob: Date.new(1991, 11, 1),
            last_name: 'foo',
            sid: 1234,
          ))

        subject
      end
    end
  end

  describe '#offender_details' do
    let(:client) { described_class.new(api_key: '123') }
    let(:search_sid) { 20130142 }

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
        expect(subject[:first]).to eq('John')
        expect(subject[:last]).to eq('Wilhite')
        expect(subject[:sid]).to eq(20130142)
      end
    end
  end
end
