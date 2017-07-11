# frozen_string_literal: true

# A utility class for tracking mixpanel events without complicating each
# call-site.
#
# This class is intended to be instantiated once per-request.
class MixpanelTrackerWrapper
  TRACK_LOG = '  [MIXPANEL] Tracking event %s: %s'

  attr_reader :distinct_id

  def self.from_request(request)
    distinct_id = request.env[MixpanelMiddleware::DISTINCT_ID]
    ip = request.remote_ip

    new(distinct_id, ip)
  end

  def initialize(distinct_id = nil, ip = nil)
    @tracker = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    @distinct_id = distinct_id
    @ip = ip
  end

  def track(event_name, event_properties)
    event_properties = self.class.flatten_properties(event_properties)
    log(event_name, event_properties)

    @tracker.track(@distinct_id, event_name, event_properties, @ip)
  end

  private

  # Converts/flattens
  #   { 'a' => { 'b' => ... } }
  # to:
  #   { 'a.b' => ... }
  def self.flatten_properties(hash, prefix: nil)
    hash.each_with_object({}) do |(k, v), h|
      elem_prefix = [prefix, k].compact.join('.')

      case v
      when Hash
        h.merge!(flatten_properties(v, prefix: elem_prefix))
      else
        h[elem_prefix] = v
      end
    end
  end

  def log(event_name, event_properties)
    Rails.logger.debug(
      format(TRACK_LOG, event_name, event_properties.to_hash.merge(distinct_id: @distinct_id)),
    )
  end
end
