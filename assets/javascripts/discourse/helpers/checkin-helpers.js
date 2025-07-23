import { registerUnbound } from "discourse-common/lib/helpers";

registerUnbound("multiply", (a, b) => {
  return (parseFloat(a) || 0) * (parseFloat(b) || 0);
});

registerUnbound("subtract", (a, b) => {
  return (parseFloat(a) || 0) - (parseFloat(b) || 0);
});

registerUnbound("round", (num) => {
  return Math.round(parseFloat(num) || 0);
});
