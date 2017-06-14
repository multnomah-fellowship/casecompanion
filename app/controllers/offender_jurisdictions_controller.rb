class OffenderJurisdictionsController < ApplicationController
  before_action :redirect_to_oregon_if_no_dcj_search, only: %i[index]

  def index
  end

  def show
  end

  def search
    @results = []

    if offender_params[:sid].present?
      # when searching for a SID, just go to /offenders/<sid> and let that page
      # do the search
      redirect_to offender_path(:oregon, offender_params[:sid])
      return
    end

    if params[:error]
      render_error(params[:error], params[:error_sid])
    else
      if %w[dcj unknown].include?(params[:jurisdiction]) &&
          Rails.application.config.flipper[:dcj_search].enabled?
        # DCJ search requires last_name and (SID|dob) for now :(
        @results.push(search_dcj)
      end

      if %w[oregon unknown].include?(params[:jurisdiction])
        @results.push(*search_oregon)
      end
    end

    @results.compact!

    if @results.present?
      @grouped_results = OffenderGrouper.new(@results).each_group
      @name_highlighter = OffenderNameHighlighter.new(offender_params)
    else
      flash.now[:error] ||= I18n.t(
        'offender_search.error_no_results_by_name',
        first_name: offender_params[:first_name],
        last_name: offender_params[:last_name]
      )
    end


    render :show
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

  def search_dcj
    offender_dob = Date.new(
      offender_params[:dob][:year].to_i,
      offender_params[:dob][:month].to_i,
      offender_params[:dob][:day].to_i
    ) rescue nil

    # sanity check the DOB that it is not too far in the past or in the future
    unless offender_dob && 120.years.ago < offender_dob && offender_dob < Date.today
      date_string =
        offender_params[:dob].values_at(:month, :day, :year).join('/')

      flash.now[:error] =
        I18n.t('offender_search.error_invalid_date', date: date_string)

      # Since DOB is required, may as well not do anything
      return
    end

    DcjClient.new.search_for_offender(
      dob: offender_dob,
      last_name: offender_params[:last_name]
    )
  end

  def search_oregon
    # otherwise, time to search by name!
    begin
      results = OffenderScraper.search_by_name(
        offender_params[:first_name],
        offender_params[:last_name]
      )

      results
    rescue OosMechanizer::Searcher::ConnectionFailed
      flash.now[:error] = I18n.t('offender_search.error_connection_failed')
    rescue OosMechanizer::Searcher::TooManyResultsError
      flash.now[:error] = I18n.t('offender_search.error_too_many_results')
    end
  end

  def render_error(error_name, error_sid)
    # if this page has an "error" query param then don't attempt a search and
    # just show that error
    case error_name
    when 'error_no_results'
      flash.now[:error] = I18n.t('offender_search.error_no_results',
                                 search_sid: error_sid)
    when 'error_connection_failed'
      flash.now[:error] = I18n.t('offender_search.error_connection_failed')
    when 'error_offender_expired'
      flash.now[:error] = I18n.t('offender_search.error_offender_expired')
    end
  end
end
