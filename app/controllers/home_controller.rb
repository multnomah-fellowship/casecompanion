class HomeController < ApplicationController
  def index
  end

  def set_tracking
    session[:distinct_id] = params[:tracking_id].to_i
    redirect_to root_path
  end
end
