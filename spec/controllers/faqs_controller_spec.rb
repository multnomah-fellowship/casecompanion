require 'rails_helper'

RSpec.describe FaqsController, type: :controller do
  describe 'faq data structure' do
    subject { described_class::FAQ_MENU }

    # this is important for URL generation
    it 'no two menu items have the same text' do
      all_text = subject.flat_map do |section|
        section[:items].map { |item| item[:text] }
      end

      expect(all_text.length).to eq(all_text.uniq.length)
    end

    it 'all menu items correspond to i18n keys' do
      subject.each do |section|
        section[:items].each do |item|
          key = "faqs.#{item[:faq]}"
          # weird expectation text... great error message.
          expect(I18n).to be_exists(key)
        end
      end
    end
  end

  describe '#index' do
    subject { get :index }

    it 'renders' do
      subject
      expect(response).to be_success
    end
  end

  describe '#show' do
    subject { get :show, params: { id: 1 } }

    it 'renders' do
      subject
      expect(response).to be_success
    end
  end
end
