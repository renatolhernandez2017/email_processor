import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.classList.add("hidden"); // Esconde o alerta
    }, this.element.dataset.homeTimeoutValue || 8000); // Usa o valor do HTML ou 8s por padrão

    setTimeout(() => this.close(), this.element.dataset.homeTimeoutValue || 8000);
  }

  close() {
    this.element.classList.add("opacity-0", "transition-opacity", "duration-500");
    setTimeout(() => this.element.remove(), 500); // Remove do DOM após a animação
  }
}
