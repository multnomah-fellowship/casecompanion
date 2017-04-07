class HomeController < ApplicationController
  def index
  end

  def notification_systems
    @sid = params[:offender_id]
  end
end
