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
end
