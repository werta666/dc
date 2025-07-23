# frozen_string_literal: true

module CheckinPlugin
  class CheckinController < ::ApplicationController
    requires_login
    before_action :ensure_plugin_enabled

    def index
      user_point = UserPoint.find_or_create_for_user(current_user)
      recent_records = current_user.checkin_records.recent.limit(30)
      
      render json: {
        user_point: serialize_user_point(user_point),
        recent_records: recent_records.map { |record| serialize_checkin_record(record) },
        can_checkin_today: user_point.can_checkin_today?,
        checkin_settings: {
          base_points: SiteSetting.checkin_base_points || 10,
          makeup_cost: SiteSetting.checkin_makeup_cost || 10,
          max_makeup_days: SiteSetting.checkin_max_makeup_days || 7,
          bonus_multipliers: {
            day_3: SiteSetting.checkin_3day_bonus_multiplier || 2.0,
            day_7: SiteSetting.checkin_7day_bonus_multiplier || 3.0,
            day_14: SiteSetting.checkin_14day_bonus_multiplier || 4.0,
            day_30: SiteSetting.checkin_30day_bonus_multiplier || 5.0
          }
        }
      }
    end

    def checkin
      user_point = UserPoint.find_or_create_for_user(current_user)
      
      unless user_point.can_checkin_today?
        return render json: { 
          success: false, 
          error: I18n.t("checkin.already_checked_in_today") 
        }
      end

      checkin_record = CheckinRecord.create_checkin(current_user)
      
      if checkin_record
        render json: {
          success: true,
          checkin_record: serialize_checkin_record(checkin_record),
          user_point: serialize_user_point(user_point.reload),
          message: I18n.t("checkin.success", points: checkin_record.points_earned)
        }
      else
        render json: {
          success: false,
          error: I18n.t("checkin.failed")
        }
      end
    end

    def makeup
      date_param = params[:date]
      
      begin
        makeup_date = Date.parse(date_param)
      rescue ArgumentError
        return render json: { 
          success: false, 
          error: I18n.t("checkin.invalid_date") 
        }
      end

      unless CheckinRecord.can_makeup?(current_user, makeup_date)
        return render json: { 
          success: false, 
          error: I18n.t("checkin.cannot_makeup") 
        }
      end

      checkin_record = CheckinRecord.create_checkin(current_user, makeup_date, is_makeup: true)
      
      if checkin_record
        user_point = UserPoint.find_or_create_for_user(current_user)
        render json: {
          success: true,
          checkin_record: serialize_checkin_record(checkin_record),
          user_point: serialize_user_point(user_point.reload),
          message: I18n.t("checkin.makeup_success", 
                         date: makeup_date.strftime("%Y-%m-%d"),
                         points: checkin_record.points_earned,
                         cost: checkin_record.makeup_cost)
        }
      else
        render json: {
          success: false,
          error: I18n.t("checkin.makeup_failed")
        }
      end
    end

    def calendar
      year = params[:year]&.to_i || Date.current.year
      month = params[:month]&.to_i || Date.current.month
      
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      
      records = current_user.checkin_records
                           .where(checkin_date: start_date..end_date)
                           .order(:checkin_date)
      
      calendar_data = {}
      records.each do |record|
        calendar_data[record.checkin_date.strftime("%Y-%m-%d")] = {
          points_earned: record.points_earned,
          is_makeup: record.is_makeup,
          consecutive_days: record.consecutive_days,
          bonus_multiplier: record.bonus_multiplier
        }
      end
      
      render json: {
        year: year,
        month: month,
        calendar_data: calendar_data,
        total_checkins: records.count
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
        last_checkin_date: user_point.last_checkin_date&.strftime("%Y-%m-%d"),
        next_bonus_multiplier: user_point.get_checkin_bonus_multiplier
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
        notes: record.notes,
        is_today: record.is_today?,
        is_yesterday: record.is_yesterday?
      }
    end
  end
end
