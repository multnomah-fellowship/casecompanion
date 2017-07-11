# frozen_string_literal: true

module OffenderJurisdictionsHelper
  def search_params
    @_search_params ||=
      params.fetch(:offender, {}).slice(:first_name, :last_name)
  end

  def emphasized_text(text)
    content_tag(:span, text, class: 'app__header--emphasis')
  end
end
