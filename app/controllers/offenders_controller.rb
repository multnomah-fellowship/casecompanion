class OffendersController < ApplicationController
  def index
  end

  def show
    @offender = OffenderScraper.offender_details(params[:id])
  end

  def search
    redirect_to offender_path(params[:offender][:sid])
  end
end
