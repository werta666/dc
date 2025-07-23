import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class CheckinStatus extends Component {
  @service currentUser;
  @service siteSettings;
  @tracked isVisible = false;

  constructor() {
    super(...arguments);
    this.isVisible = this.siteSettings.checkin_plugin_enabled && this.currentUser;
  }

  get userPoint() {
    return this.currentUser?.user_point;
  }

  get canCheckinToday() {
    return this.currentUser?.can_checkin_today;
  }

  get showCheckinReminder() {
    return this.isVisible && this.canCheckinToday;
  }

  @action
  goToCheckin() {
    this.router.transitionTo("checkin");
  }
}
