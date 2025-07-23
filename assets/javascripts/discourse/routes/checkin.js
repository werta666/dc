import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class CheckinRoute extends Route {
  model() {
    return ajax("/checkin-plugin/checkin");
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.setProperties({
      userPoint: model.user_point,
      recentRecords: model.recent_records,
      canCheckinToday: model.can_checkin_today,
      checkinSettings: model.checkin_settings
    });
  }
}
