require 'rails_helper'

RSpec.describe EmailSubscriber do
  let(:to) { 'tdooner@example.com' }
  let(:subject_line) { 'Hello from the test suite' }
  let(:mailer) { 'test_mailer' }
  let(:mailer_method) { 'test_mailer_method_here' }

  let(:fake_controller) { double(request: mixpanel_trackable_request) }
  let(:fake_message) do
    Ahoy::Message.new(
      to: to,
      token: '12312312312312312312312312312',
      utm_source: mailer,
      utm_campaign: mailer_method,
      subject: subject_line
    )
  end

  describe '#open callback' do
    subject { described_class.new.open(event) }

    describe 'given an open event' do
      let(:event) do
        {
          controller: fake_controller,
          message: fake_message
        }
      end

      it 'tracks a mixpanel event' do
        expect { subject }
          .to track_mixpanel_event('email-open', include(to: to, subject: subject_line))
      end
    end
  end

  describe '#click callback' do
    subject { described_class.new.click(event) }

    describe 'given a click event' do
      let(:event) do
        {
          controller: fake_controller,
          message: fake_message,
          url: 'http://foobar.example.com?foo=bar',
        }
      end

      it 'tracks a mixpanel event' do
        expect { subject }
          .to track_mixpanel_event('email-click', include(to: to, subject: subject_line, url: event[:url]))
      end
    end
  end
end
