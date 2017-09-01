# frozen_string_literal: true

module FeedbackResponsesHelper
  OPPOSITES = {
    thumbs_up: :thumbs_down,
    thumbs_down: :thumbs_up,
    yes_but: :thumbs_up,
  }.freeze

  def emoji_image_path(feedback, size: :default, invert: false)
    suffix = case size
             when :small
               '_small'
             when :default
               ''
             else
               raise StandardError, "Unknown emoji_image size: #{size}"
             end

    feedback_value = feedback.value.to_sym

    feedback_value = OPPOSITES[feedback_value] if invert

    case feedback_value
    when :thumbs_up
      image_path("emoji_happy#{suffix}.png")
    when :thumbs_down
      image_path("emoji_sad#{suffix}.png")
    when :yes_but
      image_path("emoji_thinking_face#{suffix}.png")
    else
      raise StandardError, "Unknown emoji_image type: #{feedback.value}"
    end
  end

  def change_my_reply_path(feedback)
    feedback_value = feedback.value.to_sym

    if OPPOSITES.exclude?(feedback_value)
      raise StandardError, "Unknown change_my_reply_path type: #{feedback.value}"
    end

    feedback_response_path(
      type: OPPOSITES[feedback_value],
      previous_feedback_id: feedback.id,
    )
  end

  def maybe_render_back_button(feedback)
    is_valid_page =
      begin
        Rails.application.routes.recognize_path(feedback.page)
      rescue
        false
      end

    return unless is_valid_page

    render_component('button', to: feedback.page) do
      raw('&larr; Go Back')
    end
  end

  # If the email is a VRN receipt, we want to render different header/footer.
  def vrn_receipt?(feedback)
    feedback.page == 'vrn-confirmation' || # legacy name
      feedback.page == 'vrn_receipt' # from: RightsMailer#vrn_receipt
  end
end
