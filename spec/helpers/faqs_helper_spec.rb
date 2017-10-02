# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FaqsHelper, type: :helper do
  describe 'faq item finding' do
    let(:item) { { text: 'foo bar baz' } }
    let(:menu) { [{ items: [item] }] }

    it 'generates a URL for a faq item and then retrieves the item' do
      expect(find_faq_item(menu, faq_slug(item))).to eq(item)
    end
  end

  describe '#faq_format' do
    let(:kwargs) { {} }

    subject { helper.faq_format(item, **kwargs) }

    context 'with a multi-line FAQ item' do
      let(:item) { <<-ITEM.strip_heredoc }
      This is a multi-line item. Break:
      Another line. Paragraph:

      Another line
      ITEM

      it 'adds line breaks and <p>s' do
        expect(subject).to include("Break:\n<br />")
        expect(subject).to include("Paragraph:</p>\n\n<p>")
      end

      it 'is html_safe' do
        expect(subject).to be_html_safe
      end
    end

    context 'with an item with HTML in it' do
      let(:item) { <<-ITEM.strip_heredoc }
      This is my item.

      <ul>
        <li>Foo Bar</li>
        <li>Baz</li>
      </ul>
      ITEM

      it 'does not include <br>s between HTML tags' do
        doc = Nokogiri::HTML(subject)
        expect(doc.css('ul > br').length).to eq(0)
      end
    end

    context 'passing an HTML class' do
      let(:item) { 'foo bar baz' }
      let(:kwargs) { { html_class: 'test-some-class' } }

      it 'uses that class' do
        doc = Nokogiri::HTML(subject)
        expect(doc.css('p')[0]['class']).to eq('test-some-class')
      end
    end

    context 'passing an HTML tag' do
      let(:item) { 'foo bar baz' }
      let(:kwargs) { { html_tag: 'div' } }

      it 'uses that tag' do
        doc = Nokogiri::HTML(subject)
        expect(doc.css('body > div')[0]).not_to be_nil
      end
    end
  end
end
