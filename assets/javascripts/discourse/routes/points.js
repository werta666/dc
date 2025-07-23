import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class PointsRoute extends Route {
  model() {
    return ajax("/checkin-plugin/points");
  }
}
