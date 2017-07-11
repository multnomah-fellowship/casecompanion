# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FaqsController, type: :controller do
  describe 'faq data structure' do
    subject { described_class::FAQ_MENU }

    def each_faq_content
      subject.each do |section|
        section[:items].each do |item|
          key = "faqs.#{item[:faq]}"
          item = I18n.t(key)

          # no nested structure:
          %i[title header].each { |k| yield(item[k]) }

          # iterate through each dropdown
          Array(item[:dropdowns]).each do |_name, dropdown|
            yield(dropdown[:title])
            yield(dropdown[:body])
          end

          # iterate through "who to call"
          Array(item[:who_to_call]).each do |who|
            yield(who[:name])
            yield(who[:phone])
          end
        end
      end
    end

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

    it 'all links open in a new window' do
      each_faq_content do |item|
        doc = Nokogiri::HTML(item)
        expect(doc.css('a')).to(be_all { |el| el[:target] == '_blank' })
      end
    end

    it 'all I18n dropdowns are objects of proper form' do
      subject.each do |section|
        section[:items].each do |item|
          key = "faqs.#{item[:faq]}"

          expect(I18n.t(key)).to be_a(Hash)
        end
      end
    end
  end

  describe '#index' do
    subject { get :index }

    it 'renders successfully' do
      subject
      expect(response).to be_success
    end
  end
end
