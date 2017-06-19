class FeedbackResponse < ApplicationRecord
  enum value: [:thumbs_up, :thumbs_down, :yes_but]
end
