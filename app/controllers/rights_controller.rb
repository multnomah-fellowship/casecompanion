class RightsController < ApplicationController
  before_action :load_or_initialize_flow
  after_action :save_flow, except: :delete

  def index
    redirect_to right_path(RightsFlow.first_step)
  end

  def show
    return render 'create' if @flow.current_page == 'confirm'

    render
  end

  def update
    @flow.assign_attributes(rights_flow_params)
    @flow.validate!

    if @flow.errors.any?
      render :show
    else
      if @flow.finished?
        @flow.persist!
        # Log in as the user
        # TODO: write a test for this
        session[:user_id] = CourtCaseSubscription.find(@flow.court_case_subscription_id).user.id
      end

      redirect_to right_path(@flow.next_step)
    end
  end

  def delete
    cookies.delete(:rights_flow)
    redirect_to right_path(RightsFlow.first_step)
  end

  private

  def rights_flow_params
    params.fetch(:rights_flow, {})
      .permit(*RightsFlow::FIELDS)
  end

  # Attempt to load the flow from the session. If it cannot be loaded, then
  # default to a new object.
  def load_or_initialize_flow
    @flow = RightsFlow.from_cookie(cookies.encrypted[:rights_flow])
    @flow ||= RightsFlow.new
    @flow.current_page = params[:id]

    if @current_user && @flow.case_number.present?
      current_subscription = CourtCaseSubscription.find_by(user: @current_user, case_number: @flow.case_number)
      @flow.court_case_subscription_id = current_subscription.try(:id)
    end
  end

  # Save the updated flow in the session.
  def save_flow
    cookies.encrypted[:rights_flow] = @flow.to_cookie
  end
end
