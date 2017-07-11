# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_edit_permission

  def edit
    @subscriptions = CourtCaseSubscription.where(user_id: @current_user)
  end

  private

  def require_edit_permission
    unless @current_user
      flash[:error] = 'You must be logged in to view this page.'
      return redirect_to new_sessions_path(next_path: request.path)
    end

    return if @current_user.is_admin

    user = User.find(params[:id])
    if user != @current_user
      flash[:error] = 'You do not have permission to view this page.'
      return redirect_to home_path
    end
  end
end
