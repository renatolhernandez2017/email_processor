import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload"
export default class extends Controller {
  static targets = ["file"]

  connect() {
    this.fileTarget.addEventListener('change', this.displayImage.bind(this));
  }

  openFileInput(event) {
    event.preventDefault();
    this.fileTarget.click();
  }

  displayImage() {
    const file = this.fileTarget.files[0];
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onload = () => {
        const img = document.createElement('img');
        img.src = reader.result;
        
        // Utilizar um target do stimulus não exibe a imagem. Por isso utilizamos o querySelector
        const previewDiv = document.querySelector('#preview');
        previewDiv.innerHTML = ''; // Limpa o conteúdo anterior, se necessário
        previewDiv.appendChild(img);
      };
      reader.readAsDataURL(file);
    } else {
      console.error("Selecione um arquivo de imagem.");
    }
  }
}
