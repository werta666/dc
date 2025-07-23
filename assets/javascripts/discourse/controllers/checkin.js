import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class CheckinController extends Controller {
  @tracked userPoint = null;
  @tracked recentRecords = [];
  @tracked canCheckinToday = false;
  @tracked checkinSettings = {};
  @tracked isLoading = false;
  @tracked selectedMakeupDate = null;

  @action
  async performCheckin() {
    if (this.isLoading || !this.canCheckinToday) return;

    this.isLoading = true;
    try {
      const result = await ajax("/checkin-plugin/checkin", {
        type: "POST"
      });

      if (result.success) {
        this.userPoint = result.user_point;
        this.recentRecords.unshiftObject(result.checkin_record);
        this.canCheckinToday = false;
        
        this.appEvents.trigger("modal-body:flash", {
          text: result.message,
          messageClass: "success"
        });
      } else {
        this.appEvents.trigger("modal-body:flash", {
          text: result.error,
          messageClass: "error"
        });
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
    }
  }

  @action
  async performMakeup() {
    if (this.isLoading || !this.selectedMakeupDate) return;

    this.isLoading = true;
    try {
      const result = await ajax("/checkin-plugin/checkin/makeup", {
        type: "POST",
        data: { date: this.selectedMakeupDate }
      });

      if (result.success) {
        this.userPoint = result.user_point;
        this.recentRecords.unshiftObject(result.checkin_record);
        this.selectedMakeupDate = null;
        
        this.appEvents.trigger("modal-body:flash", {
          text: result.message,
          messageClass: "success"
        });
      } else {
        this.appEvents.trigger("modal-body:flash", {
          text: result.error,
          messageClass: "error"
        });
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
    }
  }

  @action
  setMakeupDate(event) {
    this.selectedMakeupDate = event.target.value;
  }

  get consecutiveDaysBonus() {
    const days = this.userPoint?.consecutive_days || 0;
    const multipliers = this.checkinSettings?.bonus_multipliers || {};
    
    if (days >= 30) return multipliers.day_30 || 5.0;
    if (days >= 14) return multipliers.day_14 || 4.0;
    if (days >= 7) return multipliers.day_7 || 3.0;
    if (days >= 3) return multipliers.day_3 || 2.0;
    return 1.0;
  }

  get nextMilestone() {
    const days = this.userPoint?.consecutive_days || 0;
    
    if (days < 3) return { days: 3, bonus: this.checkinSettings?.bonus_multipliers?.day_3 || 2.0 };
    if (days < 7) return { days: 7, bonus: this.checkinSettings?.bonus_multipliers?.day_7 || 3.0 };
    if (days < 14) return { days: 14, bonus: this.checkinSettings?.bonus_multipliers?.day_14 || 4.0 };
    if (days < 30) return { days: 30, bonus: this.checkinSettings?.bonus_multipliers?.day_30 || 5.0 };
    return null;
  }

  get canAffordMakeup() {
    const cost = this.checkinSettings?.makeup_cost || 10;
    return (this.userPoint?.available_points || 0) >= cost;
  }
}
