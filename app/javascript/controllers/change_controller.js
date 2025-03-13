import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="change"
export default class extends Controller {
  connect() {
  }

  updateAddress(event) {
    const selectedOption = event.target.selectedOptions[0];

    if (!selectedOption) return;

    // Lista de campos e seus respectivos atributos no <option>
    const fields = {
      street: "data-address",
      district: "data-district",
      number: "data-number",
      complement: "data-complement",
      city: "data-city",
      uf: "data-uf",
      zip_code: "data-zip",
      phone: "data-phone",
      cellphone: "data-cellphone",
      fax: "data-fax"
    };

    Object.entries(fields).forEach(([field, attribute]) => {
      const input = document.getElementById(`prescriber_representative_attributes_address_attributes_${field}`);
      if (input) {
        input.value = selectedOption.getAttribute(attribute) || "";
        input.dispatchEvent(new Event("input")); // Garante que o Rails capture a alteração
      }
    });
  }  
}
