class HomeController < ApplicationController
  def index
    render layout: 'splash'
  end

  def set_tracking
    session[:distinct_id] = params[:tracking_id].to_i
    redirect_to root_path
  end

  def trigger_error
    raise 'Sentry testing error!'
  end
end
