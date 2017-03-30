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
end
