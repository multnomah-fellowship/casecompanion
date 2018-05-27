module Admin::ImportStatusesHelper
  def format_log_time(time_string)
    DateTime.parse(time_string)
      .in_time_zone('UTC')
      .localtime
      .strftime('%A %B %-d, %Y at %-I:%M %P')
  end
end
