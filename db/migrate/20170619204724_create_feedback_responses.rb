class CreateFeedbackResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :feedback_responses do |t|
      t.integer :value, null: false
      t.text :body

      t.timestamps
    end
  end
end
