# frozen_string_literal: true

class CreateOffenderSearchCache < ActiveRecord::Migration[5.0]
  def change
    create_table :offender_search_caches do |t|
      t.integer :offender_sid
      t.text :data

      t.timestamps

      t.index :offender_sid, unique: true
    end
  end
end
