import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  connect() {
  }

  tableTr(id) {
    const trId = id.currentTarget.dataset.trId;
    const trId2 = id.currentTarget.dataset.trId2;
    const hiddenRow = document.getElementById(trId);
    const hiddenRow2 = document.getElementById(trId2);

    if (hiddenRow) {
      hiddenRow.classList.toggle('hidden');
    }

    if (hiddenRow2) {
      hiddenRow2.classList.toggle('hidden');
    }
  }
}
