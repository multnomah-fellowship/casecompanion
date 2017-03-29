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

    "#{first} #{last}".chomp
  end

  # Names are hard, this method assumes Western naming conventions.
  def first_name(full_name)
    (full_name.include?(',') ? name_reorderer(full_name) : full_name).split.first
  end
end
