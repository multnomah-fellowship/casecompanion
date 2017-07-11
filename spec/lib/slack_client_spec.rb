# frozen_string_literal: true

require 'rails_helper'

describe SlackClient do
  let(:slack_url) { 'https://example.com/foo/bar' }
  let(:client) { SlackClient.new(hook_url: slack_url, app_name: 'MyAdvocate Test') }

  before do
    stub_request(:post, slack_url)
  end

  describe '#post_beta_signup_message' do
    let(:utm_attribution) { nil }

    let(:beta_signup) do
      BetaSignup.create(
        email: 'test@example.com',
        utm_attribution: utm_attribution,
      )
    end

    subject { client.post_beta_signup_message(beta_signup) }

    it 'posts the correct message to Slack' do
      subject

      expect(a_request(:post, slack_url).with do |req|
        payload = JSON.parse(req.body)

        expect(payload['attachments'].first['fields'])
          .to include(hash_including(
            'title' => 'Email',
            'value' => beta_signup.email,
          ))
      end).to have_been_made
    end

    describe 'with a UTM attribution' do
      let(:utm_attribution) { UtmAttribution.new(utm_campaign: 'foo') }

      it 'includes the UTM attribution' do
        subject

        expect(a_request(:post, slack_url).with do |req|
          payload = JSON.parse(req.body)

          expect(payload['attachments'].first['fields'])
            .to include(hash_including(
              'title' => 'utm_campaign',
              'value' => utm_attribution.utm_campaign,
            ))
          expect(payload['attachments'].first['fields'])
            .not_to include(hash_including('title' => 'utm_content'))
        end).to have_been_made
      end
    end
  end

  describe '#post_feedback_message' do
    let(:feedback) do
      FeedbackResponse.create(
        value: 'thumbs_up',
        page: '/give-me-feedback',
        body: 'just enough corgis',
      )
    end

    subject { client.post_feedback_message(feedback) }

    it 'posts the correct message to Slack' do
      subject

      expect(a_request(:post, slack_url).with do |req|
        payload = JSON.parse(req.body)

        expect(payload['attachments'])
          .to include(hash_including('text' => feedback.body))
      end).to have_been_made
    end
  end
end
