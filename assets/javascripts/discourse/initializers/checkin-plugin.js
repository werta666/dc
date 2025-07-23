import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "checkin-plugin",
  
  initialize() {
    withPluginApi("0.8.31", (api) => {
      // Add navigation items to user menu
      api.decorateWidget("hamburger-menu:generalLinks", (helper) => {
        if (helper.currentUser && helper.siteSettings.checkin_plugin_enabled) {
          return helper.h("li", [
            helper.h("a.widget-link", {
              href: "/checkin",
              attributes: { "data-auto-route": true }
            }, [
              helper.h("span.d-icon.d-icon-calendar-check"),
              " ",
              I18n.t("checkin.title")
            ])
          ]);
        }
      });

      // Add to user menu dropdown
      api.addUserMenuGlyph({
        label: "checkin.title",
        className: "checkin-link",
        icon: "calendar-check",
        href: "/checkin"
      });

      // Add points link to user menu
      api.addUserMenuGlyph({
        label: "points.title", 
        className: "points-link",
        icon: "coins",
        href: "/points"
      });

      // Add routes
      api.addDiscoveryQueryParam("checkin", { replace: true, refreshModel: true });
      
      // Register routes
      api.modifyClass("route:application", {
        actions: {
          showCheckin() {
            this.transitionTo("checkin");
          },
          showPoints() {
            this.transitionTo("points");
          }
        }
      });
    });
  }
};
