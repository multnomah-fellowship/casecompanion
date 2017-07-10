class AddUserInfoFieldsToCourtCaseSubscription < ActiveRecord::Migration[5.0]
  def change
    change_table :court_case_subscriptions do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
    end
  end
end
