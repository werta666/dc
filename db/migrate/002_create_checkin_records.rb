# frozen_string_literal: true

class CreateCheckinRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :checkin_records do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.date :checkin_date, null: false
      t.integer :points_earned, default: 0, null: false
      t.boolean :is_makeup, default: false, null: false
      t.integer :makeup_cost, default: 0, null: false
      t.integer :consecutive_days, default: 0, null: false
      t.float :bonus_multiplier, default: 1.0, null: false
      t.text :notes
      t.timestamps
    end

    add_index :checkin_records, [:user_id, :checkin_date], unique: true
    add_index :checkin_records, :checkin_date
    add_index :checkin_records, :is_makeup
    add_index :checkin_records, :consecutive_days
  end
end
