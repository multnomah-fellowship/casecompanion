class RightsController < ApplicationController
  before_action :load_or_initialize_flow
  after_action :save_flow, unless: :reset_flow?

  def index
    redirect_to right_path(RightsFlow.first_step)
  end

  def show
    render
  end

  def update
    if reset_flow?
      cookies.delete(:rights_flow)
      redirect_to right_path(RightsFlow.first_step)
    else
      @flow.assign_attributes(rights_flow_params)
      @flow.validate!

      if @flow.errors.any?
        render :show
      else
        @flow.persist! if @flow.finished?
        redirect_to right_path(@flow.next_step)
      end
    end
  end

  private

  def rights_flow_params
    params.fetch(:rights_flow, {})
      .permit(*RightsFlow::FIELDS)
  end

  def reset_flow?
    params[:commit] == 'Reset'
  end

  # Attempt to load the flow from the session. If it cannot be loaded, then
  # default to a new object.
  def load_or_initialize_flow
    @flow = RightsFlow.from_cookie(cookies.encrypted[:rights_flow])
    @flow ||= RightsFlow.new
    @flow.current_page = params[:id]
  end

  # Save the updated flow in the session.
  def save_flow
    cookies.encrypted[:rights_flow] = @flow.to_cookie
  end
end
