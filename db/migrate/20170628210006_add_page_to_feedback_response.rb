# frozen_string_literal: true

class AddPageToFeedbackResponse < ActiveRecord::Migration[5.0]
  def change
    change_table :feedback_responses do |t|
      t.string :page, null: false, default: 'vrn-experiment'
    end
  end
end
