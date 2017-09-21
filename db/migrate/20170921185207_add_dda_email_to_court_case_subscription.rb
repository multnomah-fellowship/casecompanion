# frozen_string_literal: true

class AddDdaEmailToCourtCaseSubscription < ActiveRecord::Migration[5.0]
  def change
    change_table :court_case_subscriptions do |t|
      t.string :dda_email
    end
  end
end
