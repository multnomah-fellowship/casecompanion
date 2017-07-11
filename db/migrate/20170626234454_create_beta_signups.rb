# frozen_string_literal: true

class CreateBetaSignups < ActiveRecord::Migration[5.0]
  def change
    create_table :beta_signups do |t|
      t.string :email, null: false
      t.references :utm_attribution

      t.timestamps
    end
  end
end
