class FeedbackResponsesController < ApplicationController
  DEFAULT_PAGE = 'vrn-experiment'

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
                    page: params[:page].presence || DEFAULT_PAGE,
                    value: params[:type]
                  )
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
