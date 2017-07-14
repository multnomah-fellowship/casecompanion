# frozen_string_literal: true

require 'rails_helper'

describe PossiblyFakeRequestIpMiddleware do
  let(:app) { proc { |_env| [200, {}, 'Response OK'] } }
  let(:env) { {} }

  subject { described_class.new(app).call(env) }

  describe 'with no X-Forwarded-For header' do
    it 'does not crash' do
      status, _headers, body = subject

      expect(status).to eq(200)
      expect(body).to eq('Response OK')
      expect(env).to include(PossiblyFakeRequestIpMiddleware::KEY => nil)
    end
  end

  describe 'with an X-Forwarded-For of a single value' do
    let(:env) { { 'HTTP_X_FORWARDED_FOR' => '1.2.3.4' } }

    it 'sets that value' do
      subject
      expect(env).to include(PossiblyFakeRequestIpMiddleware::KEY => '1.2.3.4')
    end
  end

  describe 'with an X-Forwarded-For of a multiple values' do
    let(:env) { { 'HTTP_X_FORWARDED_FOR' => '1.2.3.4, 5.6.7.8, 9.10.11.12' } }

    it 'sets the first value' do
      subject
      expect(env).to include(PossiblyFakeRequestIpMiddleware::KEY => '1.2.3.4')
    end
  end
end
