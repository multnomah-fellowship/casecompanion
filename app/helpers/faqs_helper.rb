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

  # @param body A trusted string, from I18n locale file
  # @return String An html_safe string to output.
  def faq_format(body)
    raw(simple_format(body))
  end
end
