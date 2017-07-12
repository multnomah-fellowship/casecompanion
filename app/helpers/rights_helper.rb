# frozen_string_literal: true

module RightsHelper
  # Sorts rights as the user checked them off in the Right selection flow for
  # purposes of displaying the rights to a user.
  def sort_rights_in_flow_order(rights)
    right_name_to_flag = Right::RIGHTS.invert
    flow_order = Right::GROUPS.values.flatten

    rights.sort_by do |right|
      flag = right_name_to_flag[right.name]

      flow_order.find_index(flag)
    end
  end
end
