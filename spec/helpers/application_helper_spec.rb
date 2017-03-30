require 'rails_helper'

describe ApplicationHelper do
  describe '#name_reorderer' do
    it 'reorders names correctly' do
      expect(helper.name_reorderer('Calaway, Laurel')).to eq('Laurel Calaway')
    end
  end

  describe '#first_name' do
    it 'gives first names correctly' do
      expect(helper.first_name('Calaway, Laurel')).to eq('Laurel')
      expect(helper.first_name('Laurel Calaway')).to eq('Laurel')
    end
  end

  describe '#format_phone' do
    it 'formats a phone number as intended' do
      expect(helper.format_phone('+11234567890')).to eq('(123) 456-7890')
    end
  end
end
