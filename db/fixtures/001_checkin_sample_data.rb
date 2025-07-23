# frozen_string_literal: true

# Sample data for testing the checkin plugin
# This file creates some sample checkin records for development/testing

if Rails.env.development?
  # Find or create a test user
  test_user = User.find_by(username: 'test_user') || User.create!(
    username: 'test_user',
    email: 'test@example.com',
    password: 'password123',
    active: true,
    approved: true,
    trust_level: 1
  )

  # Create user point record
  user_point = UserPoint.find_or_create_for_user(test_user)
  
  # Create some sample checkin records for the past week
  (7.days.ago.to_date..Date.current).each_with_index do |date, index|
    next if CheckinRecord.exists?(user: test_user, checkin_date: date)
    
    consecutive_days = index + 1
    base_points = 10
    
    # Calculate bonus multiplier based on consecutive days
    bonus_multiplier = case consecutive_days
    when 0..2
      1.0
    when 3..6
      2.0
    when 7..13
      3.0
    else
      4.0
    end
    
    points_earned = (base_points * bonus_multiplier).to_i
    
    CheckinRecord.create!(
      user: test_user,
      checkin_date: date,
      points_earned: points_earned,
      is_makeup: false,
      makeup_cost: 0,
      consecutive_days: consecutive_days,
      bonus_multiplier: bonus_multiplier,
      notes: "Sample checkin record for #{date}"
    )
    
    # Update user points
    user_point.total_points += points_earned
    user_point.available_points += points_earned
  end
  
  # Update final consecutive days and last checkin date
  user_point.consecutive_days = 7
  user_point.last_checkin_date = Date.current
  user_point.save!
  
  puts "Created sample checkin data for user: #{test_user.username}"
  puts "Total points: #{user_point.total_points}"
  puts "Consecutive days: #{user_point.consecutive_days}"
end
