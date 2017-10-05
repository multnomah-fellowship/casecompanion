# frozen_string_literal: true

class HomeController < ApplicationController
  REVISION_PATH = File.expand_path('../../REVISION', __FILE__)

  def splash
    return redirect_to home_path if @current_user

    render layout: 'splash'
  end

  def home
    return redirect_to root_path unless @current_user

    return unless @current_user.is_admin?

    # Admin-only stuff:
    local_crimes = LocalCrimesInPostgres.new
    @data_ranges = local_crimes.data_range
  end

  def set_tracking
    session[:distinct_id] = params[:tracking_id].to_i
    redirect_to root_path
  end

  def trigger_error
    raise 'Sentry testing error!'
  end

  def health
    info = {
      revision: File.exist?(REVISION_PATH) ? File.read(REVISION_PATH) : 'unknown',
    }

    render json: info
  end
end
