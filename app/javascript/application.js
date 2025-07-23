import "@hotwired/turbo-rails";
import "./controllers";
import "./channels/closing_channel"

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};
