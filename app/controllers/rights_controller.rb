# frozen_string_literal: true

class RightsController < ApplicationController
  before_action :load_or_initialize_flow
  after_action :save_flow
  after_action :delete_flow

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
    redirect_to right_path(RightsFlow.first_step)
  end

  def preview
    return head :not_found unless params[:format] == 'pdf'

    fake_created_at = Time.now
    subscription = CourtCaseSubscription.new(
      case_number: '1000000',
      email: 'person@example.com',
      first_name: 'Duncan',
      last_name: 'Doodlebear', # (sp?)
      phone_number: '(503) 555-1234',
      created_at: fake_created_at,
      updated_at: fake_created_at,
      checked_rights: [
        Right.new(name: Right::RIGHTS[:flag_a]),
        Right.new(name: Right::RIGHTS[:flag_b]),
        Right.new(name: Right::RIGHTS[:flag_d]),
        Right.new(name: Right::RIGHTS[:flag_k]),
        Right.new(name: Right::RIGHTS[:flag_m]),
      ],
    )

    generator = RightsPdfGenerator.new(subscription)
    generator.generate

    render body: generator.data, content_type: 'application/pdf'
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
    @flow.current_page = params[:id].presence || RightsFlow.first_step
    redirect_to right_path(@flow.redirect_to_page) if @flow.redirect_to_page
  end

  # Save the updated flow in the session.
  def save_flow
    return if should_delete_flow?
    cookies.encrypted[:rights_flow] = @flow.to_cookie
  end

  def delete_flow
    return unless should_delete_flow?
    cookies.delete(:rights_flow)
  end

  def should_delete_flow?
    @flow.current_page == 'done' || params[:action] == 'delete'
  end

  def send_rights_confirmation_email(subscription_id)
    subscription = CourtCaseSubscription.find(subscription_id)

    if subscription.email.present?
      RightsMailer
        .vrn_receipt(subscription)
        .deliver_now
    end

    RightsMailer
      .vrn_advocate_update(subscription)
      .deliver_now
  end
end
