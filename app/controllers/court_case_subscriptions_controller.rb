# frozen_string_literal: true

class CourtCaseSubscriptionsController < ApplicationController
  before_action :require_edit_permission, except: %i[show]

  def show
    @subscription = CourtCaseSubscription.find(params[:id])
  end

  def create
    subscription = CourtCaseSubscription.create(subscription_params)
    unless subscription
      flash[:error] = 'There was an error subscribing to that case: ' +
        subscription.errors.full_messages.join('<br />')
    end

    redirect_to edit_user_path(params[:user_id])
  end

  def destroy
    subscription = CourtCaseSubscription.find(params[:id])
    subscription.destroy
    redirect_to edit_user_path(subscription.user.id)
  end

  private

  def subscription_params
    params.fetch(:court_case_subscription, {})
      .permit(:case_number)
      .merge(user_id: @current_user.id)
  end

  def require_edit_permission
    # TODO: extract this into a superclass to DRY it up
    unless @current_user
      flash[:error] = 'You must be logged in to view this page.'
      return redirect_to new_sessions_path(next_path: request.path)
    end

    return if @current_user.is_admin

    user = User.find(params[:user_id])
    return if user == @current_user

    flash[:error] = 'You do not have permission to view this page.'
    redirect_to home_path
  end
end
