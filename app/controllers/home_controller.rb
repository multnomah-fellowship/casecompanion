class HomeController < ApplicationController
  def splash
    return redirect_to home_path if current_user

    render layout: 'splash'
  end

  def home
    return redirect_to root_path unless current_user
  end

  def set_tracking
    session[:distinct_id] = params[:tracking_id].to_i
    redirect_to root_path
  end

  def trigger_error
    raise 'Sentry testing error!'
  end
end
