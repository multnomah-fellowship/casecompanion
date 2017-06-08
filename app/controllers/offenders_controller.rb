class OffendersController < ApplicationController
  def index
    if offender_params[:last_name].present? && offender_params[:dcj_sid].present? &&
        Rails.application.config.flipper[:dcj_search].enabled?
      # DCJ search requires last_name and SID for now :(
      @results = [DcjClient.new.offender_details(
        sid: offender_params[:dcj_sid],
        last_name: offender_params[:last_name]
      )]
    elsif offender_params[:sid].present?
      # when searching for a SID, just go to /offenders/<sid> and let that page
      # do the search
      redirect_to offender_offenders_path(:oregon, offender_params[:sid])
    elsif params[:error]
      # if this page has an "error" query param then don't attempt a search and
      # just show that error
      case params[:error]
      when 'no_offender_found'
        flash.now[:error] = I18n.t('offender_search.error_no_results',
                                   search_sid: params[:error_sid])
      when 'error_connection_failed'
        flash.now[:error] = I18n.t('offender_search.error_connection_failed')
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

  def show
    @offender =
      case params[:jurisdiction].to_sym
      when :oregon
        OffenderScraper.offender_details(params[:id])
      when :dcj
        DcjClient.new.offender_details(sid: params[:id])
      end

    if @offender.nil?
      redirect_to offenders_path(error: 'no_offender_found', error_sid: params[:id])
    end
  rescue OosMechanizer::Searcher::ConnectionFailed
    redirect_to offenders_path(error: 'error_connection_failed')
  end

  private

  def offender_params
    params.fetch(:offender, {})
  end
end
