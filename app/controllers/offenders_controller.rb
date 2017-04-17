class OffendersController < ApplicationController
  def index
    if offender_params[:sid].present?
      redirect_to offender_path(offender_params[:sid])
    elsif offender_params[:first_name].present? || offender_params[:last_name].present?
      @results = OffenderScraper.search_by_name(
        offender_params[:first_name],
        offender_params[:last_name]
      )
    end

    if params[:error] == 'no_offender_found'
      flash.now[:error] = I18n.t(
        'offender_search.error_no_results',
        search_sid: params[:error_sid]
      )
    elsif @results && @results.empty?
      flash.now[:error] = I18n.t(
        'offender_search.error_no_results_by_name',
        first_name: offender_params[:first_name],
        last_name: offender_params[:last_name]
      )
    end
  end

  def show
    @offender = OffenderScraper.offender_details(params[:id])

    if @offender.nil?
      redirect_to offenders_path(error: 'no_offender_found', error_sid: params[:id])
    end
  end

  private

  def offender_params
    params.fetch(:offender, {})
  end
end
