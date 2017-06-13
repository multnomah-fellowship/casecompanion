class OffendersController < ApplicationController
  def index
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
      redirect_to offender_jurisdiction_path(
        error: 'error_no_results',
        error_sid: params[:id],
        jurisdiction: params[:jurisdiction]
      )
    end
  rescue OosMechanizer::Searcher::ConnectionFailed
    redirect_to offender_jurisdiction_path(
      error: 'error_connection_failed',
      jurisdiction: params[:jurisdiction]
    )
  end

  private

  def offender_params
    params.fetch(:offender, {})
  end
end
