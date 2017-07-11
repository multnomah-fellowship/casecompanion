# frozen_string_literal: true

class CreateUtmAttributions < ActiveRecord::Migration[5.0]
  def change
    create_table :utm_attributions do |t|
      t.string :utm_source
      t.string :utm_content
      t.string :utm_medium
      t.string :utm_campaign

      t.timestamps
    end
  end
end
