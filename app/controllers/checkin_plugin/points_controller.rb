# frozen_string_literal: true

module CheckinPlugin
  class PointsController < ::ApplicationController
    requires_login
    before_action :ensure_plugin_enabled

    def index
      user_point = UserPoint.find_or_create_for_user(current_user)
      
      render json: {
        user_point: serialize_user_point(user_point),
        statistics: calculate_statistics(current_user)
      }
    end

    def history
      page = params[:page]&.to_i || 1
      per_page = 20
      
      records = current_user.checkin_records
                           .order(checkin_date: :desc)
                           .offset((page - 1) * per_page)
                           .limit(per_page)
      
      total_count = current_user.checkin_records.count
      total_pages = (total_count.to_f / per_page).ceil
      
      render json: {
        records: records.map { |record| serialize_checkin_record(record) },
        pagination: {
          current_page: page,
          total_pages: total_pages,
          total_count: total_count,
          per_page: per_page
        }
      }
    end

    def leaderboard
      limit = params[:limit]&.to_i || 10
      period = params[:period] || 'all_time' # all_time, monthly, weekly
      
      case period
      when 'monthly'
        start_date = Date.current.beginning_of_month
        end_date = Date.current.end_of_month
      when 'weekly'
        start_date = Date.current.beginning_of_week
        end_date = Date.current.end_of_week
      else
        start_date = nil
        end_date = nil
      end
      
      query = UserPoint.joins(:user)
                      .where(users: { active: true })
                      .order(total_points: :desc)
                      .limit(limit)
      
      if start_date && end_date
        # For period-based leaderboard, calculate points from checkin records
        subquery = CheckinRecord.where(checkin_date: start_date..end_date)
                               .group(:user_id)
                               .sum(:points_earned)
        
        leaderboard_data = subquery.sort_by { |_, points| -points }
                                  .first(limit)
                                  .map.with_index(1) do |(user_id, points), rank|
          user = User.find(user_id)
          {
            rank: rank,
            user: serialize_user_basic(user),
            points: points,
            period: period
          }
        end
      else
        leaderboard_data = query.map.with_index(1) do |user_point, rank|
          {
            rank: rank,
            user: serialize_user_basic(user_point.user),
            points: user_point.total_points,
            consecutive_days: user_point.consecutive_days,
            period: period
          }
        end
      end
      
      # Find current user's rank
      current_user_point = UserPoint.find_or_create_for_user(current_user)
      current_user_rank = if start_date && end_date
        current_user_period_points = CheckinRecord.where(
          user: current_user,
          checkin_date: start_date..end_date
        ).sum(:points_earned)
        
        better_users_count = CheckinRecord.where(checkin_date: start_date..end_date)
                                         .group(:user_id)
                                         .having('SUM(points_earned) > ?', current_user_period_points)
                                         .count.size
        better_users_count + 1
      else
        UserPoint.where('total_points > ?', current_user_point.total_points).count + 1
      end
      
      render json: {
        leaderboard: leaderboard_data,
        current_user_rank: current_user_rank,
        period: period,
        total_users: User.where(active: true).count
      }
    end

    private

    def ensure_plugin_enabled
      raise Discourse::NotFound unless SiteSetting.checkin_plugin_enabled
    end

    def serialize_user_point(user_point)
      {
        total_points: user_point.total_points,
        available_points: user_point.available_points,
        used_points: user_point.used_points,
        consecutive_days: user_point.consecutive_days,
        last_checkin_date: user_point.last_checkin_date&.strftime("%Y-%m-%d")
      }
    end

    def serialize_checkin_record(record)
      {
        id: record.id,
        checkin_date: record.formatted_checkin_date,
        points_earned: record.points_earned,
        is_makeup: record.is_makeup,
        makeup_cost: record.makeup_cost,
        consecutive_days: record.consecutive_days,
        bonus_multiplier: record.bonus_multiplier,
        notes: record.notes
      }
    end

    def serialize_user_basic(user)
      {
        id: user.id,
        username: user.username,
        name: user.name,
        avatar_template: user.avatar_template
      }
    end

    def calculate_statistics(user)
      records = user.checkin_records
      
      {
        total_checkins: records.count,
        makeup_checkins: records.makeup_records.count,
        regular_checkins: records.regular_checkins.count,
        max_consecutive_days: records.maximum(:consecutive_days) || 0,
        total_points_from_checkins: records.sum(:points_earned),
        average_points_per_checkin: records.count > 0 ? (records.sum(:points_earned).to_f / records.count).round(2) : 0,
        first_checkin_date: records.minimum(:checkin_date)&.strftime("%Y-%m-%d"),
        last_checkin_date: records.maximum(:checkin_date)&.strftime("%Y-%m-%d"),
        this_month_checkins: records.where(checkin_date: Date.current.beginning_of_month..Date.current.end_of_month).count,
        this_week_checkins: records.where(checkin_date: Date.current.beginning_of_week..Date.current.end_of_week).count
      }
    end
  end
end
