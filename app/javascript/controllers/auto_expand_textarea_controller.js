import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-expand-textarea"
export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    this.adjustHeight()
    this.observeTabs()
  }

  adjustHeight() {
    this.textareaTargets.forEach(textarea => {
      textarea.style.height = 'auto';
      textarea.style.height = (textarea.scrollHeight) + 'px';
    });
  }

  input() {
    this.adjustHeight()
  }

  observeTabs() {
    const tabs = document.querySelectorAll('input[name="tab_graphics"]');
    tabs.forEach(tab => {
      tab.addEventListener('change', () => {
        setTimeout(() => this.adjustHeight(), 50); // Adicione um pequeno atraso para garantir que a aba foi totalmente renderizada
      });
    });
  }
}
