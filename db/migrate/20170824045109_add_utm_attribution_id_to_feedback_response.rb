class AddUtmAttributionIdToFeedbackResponse < ActiveRecord::Migration[5.0]
  def change
    change_table :feedback_responses do |t|
      t.references :utm_attribution
    end
  end
end
