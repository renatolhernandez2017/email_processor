import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="autosubmitselect"
export default class extends Controller {
  connect() {
    //console.log("connected");
  }
  submit() {
    console.log("submited");
    this.element.requestSubmit();
  }
}
