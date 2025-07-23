import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "message", "closeButton", "steps"]

  connect() {
    this.element.addEventListener("notification:show", this.handleShow.bind(this));

    // Restaura se havouver notificação salva
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
    this.updateSteps(data.step)

    if (data.status == true) {
      this.closeButtonTarget.classList.remove("hidden")
    } else {
      this.closeButtonTarget.classList.add("hidden")
    }

    sessionStorage.setItem("lastNotification", JSON.stringify(data))
  }

  updateSteps(step) {
    if (!this.hasStepsTarget) return

    const steps = this.stepsTarget.querySelectorAll("li.step")

    steps.forEach((el, index) => {
      el.classList.remove("step-primary", "step-success")

      if (step >= steps.length) {
        el.classList.add("step-success") // Tudo concluído
      } else if (index < step) {
        el.classList.add("step-primary") // Etapas concluídas
      } else {
        el.classList.add("step-neutral") // Etapas futuras
      }
    })
  }

  close() {
    this.cardTarget.classList.add("hidden")
    sessionStorage.removeItem("lastNotification")
  }
}
