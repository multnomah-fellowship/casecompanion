class CreateCourtCaseSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :court_case_subscriptions do |t|
      t.integer :user_id, null: false
      t.string :case_number, null: false

      t.index :user_id
    end
  end
end
