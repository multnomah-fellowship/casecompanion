# frozen_string_literal: true

class FeedbackResponsesController < ApplicationController
  layout 'focused'

  def show
    @feedback = FeedbackResponse.find(params[:id])
    render :update
  end

  def create
    @feedback = if params[:previous_feedback_id].present?
                  FeedbackResponse.find(params[:previous_feedback_id])
                else
                  FeedbackResponse.create(
                    page: params[:page].presence || params[:utm_campaign],
                    value: params[:type],
                    utm_attribution: UtmAttribution.new_from_params(params),
                  )
                end

    @feedback.update_attribute(:value, params[:type])
  end

  def update
    @feedback = FeedbackResponse.find(params[:id])
    @feedback.update_attributes(feedback_params)

    send_feedback_to_slack(@feedback)
  end

  private

  def feedback_params
    params.fetch(:feedback_response, {})
      .permit(:body)
  end

  def send_feedback_to_slack(feedback)
    Timeout.timeout(5) do
      slack_response =
        Rails.application.config.slack_client.post_feedback_message(feedback)

      if slack_response[:error]
        raise StandardError, "Error sending feedback to Slack: #{slack_response[:error]}"
      end
    end
  rescue => ex
    Raven.capture_exception(ex)
  end
end
