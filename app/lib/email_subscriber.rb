# This subscribes to events from the ahoy_email gem.
#
# See: https://github.com/ankane/ahoy_email#events
class EmailSubscriber
  def open(event)
    track_mixpanel_event(event[:controller].request, 'email-open', properties(event))
  end

  def click(event)
    track_mixpanel_event(event[:controller].request, 'email-click', properties(event))
  end

  private

  def track_mixpanel_event(request, event_name, event_properties)
    mixpanel = MixpanelTrackerWrapper.from_request(request)
    mixpanel.track(event_name, event_properties)
  end

  def properties(event)
    {
      to: event[:message].to,
      subject: event[:message].subject,
      url: event[:url],
      utm_source: event[:message][:utm_source],
      utm_medium: event[:message][:utm_medium],
      utm_campaign: event[:message][:utm_campaign],
      utm_term: event[:message][:utm_term],
    }
  end
end
