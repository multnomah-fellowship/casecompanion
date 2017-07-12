# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RightsHelper do
  describe '#sort_rights_in_flow_order' do
    let(:correctly_sorted_rights) do
      [
        # first, who_assert
        Right.new(name: Right::RIGHTS[:flag_a]),
        # then, to_notification
        Right.new(name: Right::RIGHTS[:flag_b]),
        Right.new(name: Right::RIGHTS[:flag_e]),
        # then, to_financial_assistance
        Right.new(name: Right::RIGHTS[:flag_k]),
        # finally, in_special_cases
        Right.new(name: Right::RIGHTS[:flag_c]),
        Right.new(name: Right::RIGHTS[:flag_m]),
      ]
    end

    subject { helper.sort_rights_in_flow_order(correctly_sorted_rights.shuffle) }

    it 'sorts according to the GROUPS array' do
      expect(subject).to eq(correctly_sorted_rights)
    end
  end
end
