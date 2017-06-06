require 'spec_helper'

describe DcjClient do
  let(:offender_hash) do
    {
      'OffenderFirstName': 'John',
      'OffenderLastName': 'Wilhite',
      'SID': 20130142,
      'DOB': '1977-11-07T00:00:00',
      'POFirstName': 'Frank',
      'POLastName': 'SomeRandomName',
      'POPhone': '503-555-1234 ext 12345',
    }
  end

  before do
    allow_any_instance_of(DcjClient).to receive(:fetch_offender_details)
      .and_return(offender_hash)
  end

  describe '#offender_details' do
    let(:client) { described_class.new(api_key: '123') }

    subject { client.offender_details(last_name: 'foo', sid: 1234) }

    it 'returns a hash of data' do
      expect(subject).to be_a(Hash)
    end
  end
end
