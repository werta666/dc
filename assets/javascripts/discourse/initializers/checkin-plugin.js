import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "checkin-plugin",

  initialize() {
    withPluginApi("0.8.31", (api) => {
      // Add routes
      api.addDiscoveryQueryParam("checkin", { replace: true, refreshModel: true });
      api.addDiscoveryQueryParam("points", { replace: true, refreshModel: true });
    });
  }
};
