class OffenderJurisdictionsController < ApplicationController
  before_action :redirect_to_oregon_if_no_dcj_search, only: %i[index]

  def index
  end

  def show
    if offender_params[:dcj_last_name].present? && offender_params[:dcj_sid].present? &&
        Rails.application.config.flipper[:dcj_search].enabled?
      # DCJ search requires last_name and SID for now :(
      @results = [DcjClient.new.search_for_offender(
        sid: offender_params[:dcj_sid],
        last_name: offender_params[:dcj_last_name]
      )]
    elsif offender_params[:sid].present?
      # when searching for a SID, just go to /offenders/<sid> and let that page
      # do the search
      redirect_to offender_path(:oregon, offender_params[:sid])
    elsif params[:error]
      # if this page has an "error" query param then don't attempt a search and
      # just show that error
      case params[:error]
      when 'error_no_results'
        flash.now[:error] = I18n.t('offender_search.error_no_results',
                                   search_sid: params[:error_sid])
      when 'error_connection_failed'
        flash.now[:error] = I18n.t('offender_search.error_connection_failed')
      when 'error_offender_expired'
        flash.now[:error] = I18n.t('offender_search.error_offender_expired')
      end
    elsif offender_params[:first_name].present? || offender_params[:last_name].present?
      # otherwise, time to search by name!
      begin
        @results = OffenderScraper.search_by_name(
          offender_params[:first_name],
          offender_params[:last_name]
        )

        if @results.empty?
          flash.now[:error] = I18n.t(
            'offender_search.error_no_results_by_name',
            first_name: offender_params[:first_name],
            last_name: offender_params[:last_name]
          )
        end
      rescue OosMechanizer::Searcher::ConnectionFailed
        @results = []
        flash.now[:error] = I18n.t('offender_search.error_connection_failed')
      rescue OosMechanizer::Searcher::TooManyResultsError
        @results = []
        flash.now[:error] = I18n.t('offender_search.error_too_many_results')
      end
    end

    if @results
      @grouped_results = OffenderGrouper.new(@results).each_group
      @name_highlighter = OffenderNameHighlighter.new(offender_params)
    end
  end

  private

  # TODO: remove this when we unflag dcj_search
  def redirect_to_oregon_if_no_dcj_search
    unless Rails.application.config.flipper[:dcj_search].enabled?
      redirect_to offender_jurisdiction_path(:oregon)
    end
  end

  def offender_params
    params.fetch(:offender, {})
  end
end
