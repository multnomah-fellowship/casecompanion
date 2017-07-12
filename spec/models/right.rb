# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Right do
  describe 'Right::GROUPS constant' do
    it 'contains all RIGHTS once' do
      group_contents = Right::GROUPS.values.flatten

      Right::RIGHTS.keys.each do |k|
        expect(group_contents).to include(k)
      end

      expect(group_contents | group_contents).to eq(group_contents)
    end
  end
end
