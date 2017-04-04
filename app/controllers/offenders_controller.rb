class OffendersController < ApplicationController
  def index
  end

  def show
    @offender = OffenderScraper.offender_details(params[:id])

    if @offender.nil?
      flash[:error] = <<-ERROR.strip_heredoc
        We couldn't find that offender. You may want to double-check the SID you
        used to search.

        We currently only have information on offenders in the prison system–if
        the offender with SID #{params[:id]} is not currently in a state prison
        then we will not have their information.
      ERROR

      redirect_to offenders_path
    end
  end

  def search
    redirect_to offender_path(params[:offender][:sid])
  end
end
