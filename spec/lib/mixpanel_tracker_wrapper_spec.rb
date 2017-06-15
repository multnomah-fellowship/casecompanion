require 'rails_helper'

describe MixpanelTrackerWrapper do
  describe '.from_request' do
    let(:distinct_id) { 'THISISMYDISTINCTID' }
    let(:env) { { MixpanelMiddleware::DISTINCT_ID => distinct_id } }
    let(:request) { Rack::Request.new(env) }

    subject { MixpanelTrackerWrapper.from_request(request) }

    it 'sets distinct_id from the request' do
      expect(subject.distinct_id).to eq(distinct_id)
    end
  end
end
