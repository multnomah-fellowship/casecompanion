# frozen_string_literal: true

# Syntax:
#
# expect { subject }
#   .to track_mixpanel_event('search', include(jurisdiction: 'oregon'))
RSpec::Matchers.define :track_mixpanel_event do |event, attributes|
  match do |actual|
    fake_client = instance_double('MixpanelTrackerWrapper', track: nil)

    allow(MixpanelTrackerWrapper)
      .to receive(:from_request)
      .and_return(fake_client)

    expect(fake_client)
      .to receive(:track)
      .with(event, attributes)

    actual.call
  end

  supports_block_expectations
end
