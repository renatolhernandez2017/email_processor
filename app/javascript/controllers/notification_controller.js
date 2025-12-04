import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "card", "message", "customersButton", "logsButton", "closeButton",
    "steps", "waiting", "error", "success", "line"
  ]

  connect() {
    close();
    this.element.addEventListener("notification:show", this.handleShow.bind(this));

    // Restaura se houver notificação salva
    const savedNotification = sessionStorage.getItem("lastNotification")
    if (savedNotification) {
      this.show(JSON.parse(savedNotification))
    }
  }

  handleShow(event) {
    this.show(event.detail)
  }

  show(data) {
    this.messageTarget.textContent = data.message
    this.cardTarget.classList.remove("hidden")

    if (data.status == true) {
      this.successTarget.classList.remove("hidden")
      this.waitingTarget.classList.add("hidden")
      this.errorTarget.classList.add("hidden")

      this.lineTarget.classList.remove("hidden")
      this.customersButtonTarget.classList.remove("hidden")
      this.logsButtonTarget.classList.remove("hidden")
      this.closeButtonTarget.classList.remove("hidden")
    } else {
      this.waitingTarget.classList.remove("hidden")
      this.errorTarget.classList.add("hidden")
      this.successTarget.classList.add("hidden")

      this.lineTarget.classList.add("hidden")
      this.customersButtonTarget.classList.add("hidden")
      this.logsButtonTarget.classList.add("hidden")
      this.closeButtonTarget.classList.add("hidden")
    }

    sessionStorage.setItem("lastNotification", JSON.stringify(data))
  }

  close() {
    this.cardTarget.classList.add("hidden")
    sessionStorage.removeItem("lastNotification")
    this.waitingTarget.classList.remove("hidden")
    this.errorTarget.classList.add("hidden")
    this.successTarget.classList.add("hidden")
    window.location.reload()
  }
}
