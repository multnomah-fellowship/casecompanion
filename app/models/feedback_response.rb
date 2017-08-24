# frozen_string_literal: true

class FeedbackResponse < ApplicationRecord
  belongs_to :utm_attribution, optional: true
  accepts_nested_attributes_for :utm_attribution

  enum value: %i[thumbs_up thumbs_down yes_but]
end
