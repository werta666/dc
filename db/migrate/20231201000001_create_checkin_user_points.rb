# frozen_string_literal: true

class CreateCheckinUserPoints < ActiveRecord::Migration[6.0]
  def change
    create_table :checkin_user_points do |t|
      t.integer :user_id, null: false
      t.integer :total_points, default: 0, null: false
      t.integer :available_points, default: 0, null: false
      t.integer :used_points, default: 0, null: false
      t.integer :consecutive_days, default: 0, null: false
      t.date :last_checkin_date
      t.timestamps
    end

    add_index :checkin_user_points, :user_id, unique: true
    add_index :checkin_user_points, :total_points
    add_index :checkin_user_points, :consecutive_days
  end
end
