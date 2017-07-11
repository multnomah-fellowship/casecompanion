# frozen_string_literal: true

class AddTimestampsToCourtCaseSubscritpion < ActiveRecord::Migration[5.0]
  def change
    change_table :court_case_subscriptions do |t|
      t.timestamps default: Time.now
    end

    change_column :court_case_subscriptions, :created_at, :datetime, default: nil
    change_column :court_case_subscriptions, :updated_at, :datetime, default: nil
  end
end
