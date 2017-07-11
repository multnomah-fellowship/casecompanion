# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.string :phone_number
      t.string :first_name
      t.string :offender_sid

      t.timestamps
    end
  end
end
