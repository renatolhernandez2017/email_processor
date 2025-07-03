import "@hotwired/turbo-rails";
import "./controllers";
import "./channels/closing_channel"
import "./custom/flash"

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};
