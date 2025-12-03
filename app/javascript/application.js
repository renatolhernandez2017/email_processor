import "@hotwired/turbo-rails";
import "./controllers";
import "./channels/email_channel"

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};
