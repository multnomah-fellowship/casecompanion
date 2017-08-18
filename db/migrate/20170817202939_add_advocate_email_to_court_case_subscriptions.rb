class AddAdvocateEmailToCourtCaseSubscriptions < ActiveRecord::Migration[5.0]
  def change
    change_table :court_case_subscriptions do |t|
      t.string :advocate_email
    end
  end
end
