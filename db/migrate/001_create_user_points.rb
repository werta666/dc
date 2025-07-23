# frozen_string_literal: true

class CreateUserPoints < ActiveRecord::Migration[7.0]
  def change
    create_table :user_points do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.integer :total_points, default: 0, null: false
      t.integer :available_points, default: 0, null: false
      t.integer :used_points, default: 0, null: false
      t.integer :consecutive_days, default: 0, null: false
      t.date :last_checkin_date
      t.timestamps
    end

    add_index :user_points, :user_id, unique: true
    add_index :user_points, :total_points
    add_index :user_points, :consecutive_days
  end
end
