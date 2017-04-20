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

  # Keys found with:
  #   cat scraped/statuses-2017-03-30.json | jq -r .location | sort | uniq
  # Values found in: https://www.oregon.gov/doc/docs/pdf/doc_acronyms.pdf
  INSTITUTION_ACRONYMS = {
    'Cccf Minimum'                                   => 'CCCM',
    'Coffee Creek Correctional Facility'             => 'CCCF',
    'Coffee Creek Intake Center'                     => 'CCIC',
    'Columbia River Correctional Institution'        => 'CRCI',
    'Drci Minimum'                                   => 'DRCM',
    'Eastern Oregon Correctional Institution'        => 'EOCI',
    'Ibro Location For Offenders Escaped From Leave' => '',
    'Mill Creek Correctional Facility'               => 'MCCF',
    'Oregon State Correctional Institution'          => 'OSCI',
    'Oregon State Penitentiary'                      => 'OSP',
    'Powder River Correctional Facility'             => 'PRCF',
    'Santiam Correctional Institution'               => 'SCI',
    'Shutter Creek Correctional Institution'         => 'SCCI',
    'Snake River Correctional Institution'           => 'SRCI',
    'South Fork Forest Camp'                         => 'SFFC',
    'Srci Minimum'                                   => 'SRCM',
    'Trci Minimum'                                   => 'TRCM',
    'Two Rivers Correctional Institution'            => 'TRCI',
    'Warner Creek Correctional Facility'             => 'WCCF',
  }

  # Given a counselor and a full institution name, produce a shortened title for
  # that counselor, like "Counselor, OSCI"
  def short_counselor_title(institution_name)
    if acronym = INSTITUTION_ACRONYMS[institution_name].presence
      "Counselor, #{acronym}"
    else
      'Counselor'
    end
  end

  def vine_path(offender_sid = nil)
    if offender_sid
      "https://www.vinelink.com/vinelink/servlet/SubjectSearch?siteID=38000&agency=900&offenderID=#{offender_sid}"
    else
      'https://www.vinelink.com/#/home/site/38000'
    end
  end

  def render_component(name, options = {}, &block)
    if block
      render(
        layout: "#{name}/index",
        locals: { options: options },
        &block
      )
    else
      render(partial: "#{name}/index", locals: { options: options })
    end
  rescue => ex
    raise StandardError.new("Error rendering component #{name}: #{ex.message}")
  end
end
