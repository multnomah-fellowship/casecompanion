class OffenderNameHighlighter
  include ActionView::Helpers::SanitizeHelper

  HIGHLIGHT_FIELD_NAMES = %i[first_name last_name dcj_last_name]

  def initialize(search_params)
    @search_params = search_params
  end

  def highlight(text)
    text = sanitize(text)
    regex_str = @search_params.values_at(*HIGHLIGHT_FIELD_NAMES)
      .compact
      .map { |val| Regexp.escape(val) }
      .join('|')
    text.gsub!(/(\b)(#{regex_str})(\b)/i, '\1<strong>\2</strong>\3')
    text.html_safe
  end
end
