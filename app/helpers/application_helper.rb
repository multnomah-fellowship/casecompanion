module ApplicationHelper
  def current_user
    @current_user ||= if session[:user_id]
                        User.find(session[:user_id])
                      end
  end

  # Reorders a name if it contains a comma. E.g. given "Smith, Joe" will return
  # "Joe Smith"
  def name_reorderer(full_name)
    return full_name unless full_name.include?(',')

    last, first = full_name.split(',', 2)

    "#{first} #{last}".chomp.strip
  end

  # Names are hard, this method assumes western naming conventions, that the
  # first name is the given name.
  def first_name(full_name)
    (full_name.include?(',') ? name_reorderer(full_name) : full_name).split.first
  end

  # Given a phone number like '+11234567890', returns '(123) 456-7890'
  def format_phone(phone_number)
    local_number = phone_number.gsub(/^\+1/, '')

    "(#{local_number[0..2]}) #{local_number[3..5]}-#{local_number[6..9]}"
  end

  # Handles the logic for whether to link to the offender page directly, or to
  # link to the search page if the notification is for an unknown offender
  def link_path_for_offender_or_search(notification)
    return offenders_path unless notification
    return offenders_path if notification.offender_sid == Notification::UNKNOWN_SID

    offender_path(notification.offender_sid)
  end

  # surround "\n\n" chunks with a <p>, that's it.
  def simpler_format(error)
    sanitize(error).split("\n\n").map { |chunk| content_tag(:p, chunk) }
      .join
      .html_safe
  end

  # track a message in mixpanel
  # "level" is something like :info or :error
  def mixpanel_track_message(level, message)
    first_line = message.split("\n\n", 2).first
    event_data = { level: level, message: message, first_line: first_line }

    content_tag(:script, <<-SCRIPT.strip_heredoc.html_safe)
      mixpanel.track('message-seen', #{JSON.generate(event_data)});
    SCRIPT
  end
end
