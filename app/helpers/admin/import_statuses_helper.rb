module Admin::ImportStatusesHelper
  def format_log_time(time_string)
    Time.zone
      .utc_to_local(DateTime.parse(time_string))
      .strftime('%A %B %-d, %Y at %-I:%M %P')
  end
end
