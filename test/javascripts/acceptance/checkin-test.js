import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

acceptance("Checkin Plugin", function (needs) {
  needs.user();
  needs.settings({ checkin_plugin_enabled: true });

  test("visiting /checkin", async function (assert) {
    await visit("/checkin");
    
    assert.ok(exists(".checkin-container"), "checkin page loads");
    assert.ok(exists(".checkin-header"), "checkin header is present");
    assert.ok(exists(".user-points-summary"), "points summary is shown");
  });

  test("visiting /points", async function (assert) {
    await visit("/points");
    
    assert.ok(exists(".points-container"), "points page loads");
    assert.ok(exists(".points-header"), "points header is present");
    assert.ok(exists(".points-tabs"), "points tabs are shown");
  });
});
