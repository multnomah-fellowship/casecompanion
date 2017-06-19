class FeedbackResponsesController < ApplicationController
  layout 'focused'

  def create
    @feedback = if params[:previous_feedback_id].present?
                  FeedbackResponse.find(params[:previous_feedback_id])
                else
                  FeedbackResponse.create(value: params[:type])
                end

    @feedback.update_attribute(:value, params[:type])
  end

  def update
    @feedback = FeedbackResponse.find(params[:id])
    @feedback.update_attributes(feedback_params)
  end

  private

  def feedback_params
    params.fetch(:feedback_response, {})
      .permit(:body)
  end
end
