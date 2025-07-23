import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model() {
    return ajax("/checkin-plugin/checkin");
  },

  setupController(controller, model) {
    this._super(controller, model);
    controller.setProperties({
      userPoint: model.user_point,
      recentRecords: model.recent_records,
      canCheckinToday: model.can_checkin_today,
      checkinSettings: model.checkin_settings
    });
  }
});
