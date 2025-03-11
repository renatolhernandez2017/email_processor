import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  connect() {
  }

  tableTr(id) {
    const trId = id.currentTarget.dataset.trId;
    const hiddenRow = document.getElementById(trId);

    if (hiddenRow) {
      hiddenRow.classList.toggle('hidden');
    }
  }
}
