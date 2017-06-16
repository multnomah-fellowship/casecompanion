# A utility class for tracking mixpanel events without complicating each
# call-site.
#
# This class is intended to be instantiated once per-request.
class MixpanelTrackerWrapper
  TRACK_LOG = '  [MIXPANEL] Tracking event %s: %s'

  attr_reader :distinct_id

  def self.from_request(request)
    distinct_id = request.env[MixpanelMiddleware::DISTINCT_ID]
    ip = request.ip

    new(distinct_id, ip)
  end

  def initialize(distinct_id = nil, ip = nil)
    @tracker = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    @distinct_id = distinct_id
    @ip = ip
  end

  def track(event_name, event_attributes)
    log(event_name, event_attributes)
    @tracker.track(@distinct_id, event_name, event_attributes)
  end

  private

  def log(event_name, event_attributes)
    Rails.logger.debug(TRACK_LOG % [
      event_name,
      event_attributes.to_hash.merge(distinct_id: @distinct_id)
    ])
  end
end
