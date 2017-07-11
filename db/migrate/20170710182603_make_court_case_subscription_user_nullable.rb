# frozen_string_literal: true

class MakeCourtCaseSubscriptionUserNullable < ActiveRecord::Migration[5.0]
  def change
    change_column :court_case_subscriptions, :user_id, :integer, null: true
  end
end
