# frozen_string_literal: true

require 'rails_helper'

describe MixpanelMiddleware do
  let(:app) { proc { |_env| [200, {}, 'Response OK'] } }
  let(:env) { {} }
  let(:mixpanel_token) { 'token_here' }

  subject { described_class.new(app, mixpanel_token).call(env) }

  describe 'with no cookie header' do
    it 'sets the distinct_id to nil' do
      subject
      expect(env[MixpanelMiddleware::DISTINCT_ID]).to eq(nil)
    end
  end

  describe 'with a proper cookie header from mixpanel' do
    let(:distinct_id) { 'HELLOIAMADISTINCTID' }

    let(:env) do
      key   = "mp_#{mixpanel_token}_mixpanel"
      value = JSON.generate(distinct_id: distinct_id)

      { 'HTTP_COOKIE' => "#{key}=#{value}" }
    end

    it 'sets the distinct_id to the proper value' do
      subject
      expect(env[MixpanelMiddleware::DISTINCT_ID]).to eq(distinct_id)
    end
  end
end
