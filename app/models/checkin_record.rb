# frozen_string_literal: true

class CheckinRecord < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :checkin_date, presence: true, uniqueness: { scope: :user_id }
  validates :points_earned, :makeup_cost, :consecutive_days, 
            presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :bonus_multiplier, presence: true, numericality: { greater_than: 0 }

  scope :for_user, ->(user) { where(user: user) }
  scope :for_date, ->(date) { where(checkin_date: date) }
  scope :makeup_records, -> { where(is_makeup: true) }
  scope :regular_checkins, -> { where(is_makeup: false) }
  scope :recent, -> { order(checkin_date: :desc) }

  def self.create_checkin(user, date = Date.current, is_makeup: false)
    return nil if exists?(user: user, checkin_date: date)

    user_point = UserPoint.find_or_create_for_user(user)
    
    # Handle makeup checkin
    if is_makeup
      makeup_cost = SiteSetting.checkin_makeup_cost || 10
      return nil unless user_point.available_points >= makeup_cost
      
      user_point.use_points(makeup_cost, "makeup_checkin")
    end

    # Calculate consecutive days and bonus
    if is_makeup
      consecutive_days = user_point.consecutive_days
    else
      user_point.update_consecutive_days(date)
      consecutive_days = user_point.consecutive_days
    end

    bonus_multiplier = user_point.get_checkin_bonus_multiplier
    base_points = SiteSetting.checkin_base_points || 10
    points_earned = (base_points * bonus_multiplier).to_i

    # Create checkin record
    checkin_record = create!(
      user: user,
      checkin_date: date,
      points_earned: points_earned,
      is_makeup: is_makeup,
      makeup_cost: is_makeup ? makeup_cost : 0,
      consecutive_days: consecutive_days,
      bonus_multiplier: bonus_multiplier
    )

    # Add points to user
    user_point.add_points(points_earned, "daily_checkin")

    checkin_record
  end

  def self.can_makeup?(user, date)
    return false if date >= Date.current
    return false if exists?(user: user, checkin_date: date)
    
    # Check if date is within makeup allowed range
    max_makeup_days = SiteSetting.checkin_max_makeup_days || 7
    return false if date < Date.current - max_makeup_days.days

    user_point = UserPoint.find_or_create_for_user(user)
    makeup_cost = SiteSetting.checkin_makeup_cost || 10
    
    user_point.available_points >= makeup_cost
  end

  def formatted_checkin_date
    checkin_date.strftime("%Y-%m-%d")
  end

  def is_today?
    checkin_date == Date.current
  end

  def is_yesterday?
    checkin_date == Date.current - 1.day
  end
end
