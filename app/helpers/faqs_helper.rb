# frozen_string_literal: true

module FaqsHelper
  def find_faq_item(menu, id)
    menu.each do |section|
      section[:items].each do |item|
        if item[:text].downcase.scan(/\w+/).first(10).join('-') == id
          return item
        end
      end
    end
  end

  def faq_slug(item)
    item[:text].downcase.scan(/\w+/).first(10).join('-')
  end

  # Format a string with HTML lines adjoined so it doesn't end up with <br />s
  # between.
  #
  # @param body A trusted string, from I18n locale file
  # @return String An html_safe string to output.
  def faq_format(body, html_class: nil, html_tag: nil)
    html_options = {}
    html_options[:class] = html_class if html_class

    options = { sanitize: false }
    options[:wrapper_tag] = html_tag if html_tag

    body_without_whitespace = body.gsub(/>\s+</, '><')
    raw(simple_format(body_without_whitespace, html_options, **options))
  end
end
