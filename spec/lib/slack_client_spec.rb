# frozen_string_literal: true

require 'rails_helper'

describe SlackClient do
  let(:slack_url) { 'https://example.com/foo/bar' }
  let(:client) { SlackClient.new(hook_url: slack_url, app_name: 'Case Companion Test') }

  before do
    stub_request(:post, slack_url)
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
