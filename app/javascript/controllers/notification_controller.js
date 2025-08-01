import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "message", "closeButton", "steps", "waiting", "error", "success"]

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

    if (data.step < 7) {
      sessionStorage.setItem("lastStep", data.step)
    }

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
      const lastStep = sessionStorage.getItem("lastStep")
      el.classList.remove("step-primary", "step-success", "step-error")

      if (step === steps.length) {
        el.classList.add("step-success") // Todas concluídas
        this.waitingTarget.classList.add("hidden")
        this.errorTarget.classList.add("hidden")
        this.successTarget.classList.remove("hidden")
      } else if (step === 7) {
        if (lastStep > index + 1) {
          el.classList.add("step-primary") // Concluídas
        } else if (index === lastStep - 1) {
          el.classList.add("step-error") // Etapa com erro
          this.waitingTarget.classList.add("hidden")
          this.errorTarget.classList.remove("hidden")
          this.successTarget.classList.add("hidden")
        }
      } else if (index < step) {
        el.classList.add("step-primary") // Etapas concluídas
        this.waitingTarget.classList.remove("hidden")
        this.errorTarget.classList.add("hidden")
        this.successTarget.classList.add("hidden")
      }
    })
  }

  close() {
    this.cardTarget.classList.add("hidden")
    sessionStorage.removeItem("lastNotification")
    sessionStorage.removeItem("lastStep")
    this.waitingTarget.classList.remove("hidden")
    this.errorTarget.classList.add("hidden")
    this.successTarget.classList.add("hidden")
    window.location.reload()
  }
}
