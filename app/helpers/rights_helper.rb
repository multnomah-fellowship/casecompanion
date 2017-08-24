# frozen_string_literal: true

module RightsHelper
  # Sorts rights as the user checked them off in the Right selection flow for
  # purposes of displaying the rights to a user.
  def sort_rights_in_flow_order(rights)
    right_name_to_flag = Right::RIGHTS.invert

    rights.sort_by do |right|
      flag = right_name_to_flag[right.name]

      sorted_right_flags.find_index(flag)
    end
  end

  # List of right flags (e.g. :flag_a, :flag_b) in flow order.
  def sorted_right_flags
    @_sorted_right_flags ||= Right::GROUPS.values.flatten
  end

  def right_text(right)
    right_name_to_flag = Right::RIGHTS.invert

    t("rights.#{right_name_to_flag[right.name]}")
  end
end
