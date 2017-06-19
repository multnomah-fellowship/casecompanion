module FeedbackResponsesHelper
  def emoji_image_path(feedback)
    case feedback.value.to_sym
    when :thumbs_up
      image_path('emoji_happy.png')
    when :thumbs_down
      image_path('emoji_sad.png')
    when :yes_but
      image_path('emoji_thinking_face.png')
    else
      raise StandardError.new("Unknown emoji_image type: #{feedback.value}")
    end
  end

  def change_my_reply_path(feedback)
    case feedback.value.to_sym
    when :thumbs_up
      feedback_response_path(type: 'thumbs_down', previous_feedback_id: feedback.id)
    when :thumbs_down, :yes_but
      feedback_response_path(type: 'thumbs_up', previous_feedback_id: feedback.id)
    else
      raise StandardError.new("Unknown change_my_reply_path type: #{feedback.value}")
    end
  end
end
