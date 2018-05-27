module Admin::ImportStatusesHelper
  def format_log_time(time_string)
    Time
      .parse(time_string + ' UTC')
      .in_time_zone
      .strftime('%A %B %-d, %Y at %-I:%M %P')
  end
end
