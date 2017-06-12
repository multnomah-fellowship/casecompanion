module OffenderJurisdictionsHelper
  def search_params
    @_search_params ||=
      params.fetch(:offender, {}).slice(:first_name, :last_name)
  end
end
