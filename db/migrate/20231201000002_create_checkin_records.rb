# frozen_string_literal: true

class CreateCheckinRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :checkin_records do |t|
      t.integer :user_id, null: false
      t.date :checkin_date, null: false
      t.integer :points_earned, default: 0, null: false
      t.boolean :is_makeup, default: false, null: false
      t.integer :makeup_cost, default: 0, null: false
      t.integer :consecutive_days, default: 0, null: false
      t.decimal :bonus_multiplier, precision: 3, scale: 1, default: 1.0, null: false
      t.text :notes
      t.timestamps
    end

    add_index :checkin_records, :user_id
    add_index :checkin_records, [:user_id, :checkin_date], unique: true
    add_index :checkin_records, :checkin_date
    add_index :checkin_records, :is_makeup
    add_index :checkin_records, :consecutive_days
  end
end
