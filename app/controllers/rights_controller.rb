# frozen_string_literal: true

class RightsController < ApplicationController
  before_action :load_or_initialize_flow
  after_action :save_flow, except: :delete

  def index
    redirect_to right_path(RightsFlow.first_step)
  end

  def show
    return render 'create' if @flow.current_page == 'done'

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

        send_rights_confirmation_email(@flow.court_case_subscription_id)
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
  end

  # Save the updated flow in the session.
  def save_flow
    cookies.encrypted[:rights_flow] = @flow.to_cookie
  end

  def send_rights_confirmation_email(subscription_id)
    subscription = CourtCaseSubscription.find(subscription_id)

    RightsMailer
      .vrn_receipt(subscription)
      .deliver_now

    RightsMailer
      .vrn_advocate_update(subscription)
      .deliver_now
  end
end
