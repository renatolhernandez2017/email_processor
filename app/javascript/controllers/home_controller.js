import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.classList.add("hidden"); // Esconde o alerta
    }, this.timeoutValue || 10000); // Usa o valor do HTML ou 7s por padrão

    setTimeout(() => this.close(), this.timeoutValue || 10000);
  }

  close() {
    this.element.classList.add("opacity-0", "transition-opacity", "duration-500");
    setTimeout(() => this.element.remove(), 500); // Remove do DOM após a animação
  }
}
