# frozen_string_literal: true

class FeedbackResponse < ApplicationRecord
  enum value: %i[thumbs_up thumbs_down yes_but]
end
