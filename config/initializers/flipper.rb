# frozen_string_literal: true

# Use flipper's memory adapter for now, since we don't need to share the state
# between application processes yet.
#
# Eventually we might want to gradually roll out features, but right now we will
# just use flipper for environment-based toggling.
require 'flipper/adapters/memory'
Rails.application.config.flipper = Flipper.new(Flipper::Adapters::Memory.new)

# Enable a feature flag by setting an environment variable:
# E.g. to enable feature `foo` and `bar` set `FEATURES_ENABLED=foo,bar`
ENV.fetch('FEATURES_ENABLED', '').split(',').each do |feature|
  Rails.application.config.flipper[feature.to_sym].enable
end
