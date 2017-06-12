class CreateRights < ActiveRecord::Migration[5.0]
  def change
    create_table :rights do |t|
      t.string :name, null: false
      t.references :court_case_subscription, null: false
    end
  end
end
