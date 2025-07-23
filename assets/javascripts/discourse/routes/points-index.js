import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model() {
    return ajax("/checkin-plugin/points");
  },

  setupController(controller, model) {
    this._super(controller, model);
    controller.setProperties({
      userPoint: model.user_point,
      statistics: model.statistics
    });
    
    // Load initial history and leaderboard
    controller.loadHistory(1);
    controller.loadLeaderboard("all_time");
  }
});
