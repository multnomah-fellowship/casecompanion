require 'rails_helper'

RSpec.describe FaqsHelper, type: :helper do
  describe 'faq item finding' do
    let(:item) { { text: 'foo bar baz' } }
    let(:menu) { [{ items: [item] }]  }

    it 'generates a URL for a faq item and then retrieves the item' do
      expect(find_faq_item(menu, faq_slug(item))).to eq(item)
    end
  end
end
