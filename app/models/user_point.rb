# frozen_string_literal: true

class UserPoint < ActiveRecord::Base
  belongs_to :user
  has_many :checkin_records, through: :user

  validates :user_id, presence: true, uniqueness: true
  validates :total_points, :available_points, :used_points, :consecutive_days, 
            presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.find_or_create_for_user(user)
    find_or_create_by(user: user) do |user_point|
      user_point.total_points = 0
      user_point.available_points = 0
      user_point.used_points = 0
      user_point.consecutive_days = 0
    end
  end

  def add_points(amount, reason = nil)
    return false if amount <= 0

    self.total_points += amount
    self.available_points += amount
    save!
    
    # Log the points transaction if needed
    true
  end

  def use_points(amount, reason = nil)
    return false if amount <= 0 || available_points < amount

    self.available_points -= amount
    self.used_points += amount
    save!
    
    true
  end

  def can_checkin_today?
    return true if last_checkin_date.nil?
    last_checkin_date < Date.current
  end

  def update_consecutive_days(checkin_date)
    if last_checkin_date.nil?
      self.consecutive_days = 1
    elsif last_checkin_date == checkin_date - 1.day
      self.consecutive_days += 1
    else
      self.consecutive_days = 1
    end
    
    self.last_checkin_date = checkin_date
    save!
  end

  def reset_consecutive_days
    self.consecutive_days = 0
    save!
  end

  def get_checkin_bonus_multiplier
    case consecutive_days
    when 0..2
      1.0
    when 3..6
      SiteSetting.checkin_3day_bonus_multiplier || 2.0
    when 7..13
      SiteSetting.checkin_7day_bonus_multiplier || 3.0
    when 14..29
      SiteSetting.checkin_14day_bonus_multiplier || 4.0
    else
      SiteSetting.checkin_30day_bonus_multiplier || 5.0
    end
  end
end
