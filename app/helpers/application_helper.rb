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
end
