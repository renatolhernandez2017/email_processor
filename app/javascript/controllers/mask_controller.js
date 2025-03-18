import { Controller } from "@hotwired/stimulus"
import IMask from "imask"

export default class extends Controller {
  static targets = [
    "phoneMask", "mobileMask", "cnpjMask", "cpfMask", "cepMask", "moneyMask", "percentageMask", "ufMask"
  ]

  connect() {
    this.applyMasks()
  }

  applyMasks() {
    // Máscaras de telefone
    const phoneElements = this.phoneMaskTargets.concat(this.mobileMaskTargets)
    const phoneMaskOptions = {
      mask: [
        "(00) 0000-0000", "(00) 00000-0000", "+00 (00) 0000-0000", "+00 (00) 00000-0000",
        "+1 (000) 000-0000", "(000) 000-0000", "+34 000 000 000", "000 000 000"
      ]
    }

    // Aplicando a máscara no campo sem modificar manualmente o valor
    phoneElements.forEach((element) => {
      IMask(element, phoneMaskOptions);
    });

    // Máscara de CNPJ
    this.cnpjMaskTargets.forEach((element) => {
      IMask(element, { mask: "00.000.000/0000-00" })
    })

    // Máscara de CPF
    this.cpfMaskTargets.forEach((element) => {
      IMask(element, {
        mask: [
          "000.000.000-00",
          "000.000.000-X"
        ],
        blocks: {
          X: {
            mask: IMask.MaskedEnum,
            enum: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "x", "X"]
          }
        }
      })
    })

    // Máscara de CEP
    this.cepMaskTargets.forEach((element) => {
      IMask(element, { mask: "00000-000" })
    })

    this.moneyMaskTargets.forEach((element) => {
      // Converte o valor salvo no banco para o formato correto antes de aplicar a máscara
      if (element.value) {
        let normalizedValue = parseFloat(element.value.replace(',', '.')); // Garante que o separador decimal esteja correto
        if (!isNaN(normalizedValue)) {
          element.value = normalizedValue.toFixed(2).replace('.', ','); // Mantém 2 casas decimais e substitui '.' por ','
        }
      }

      // Aplica a máscara de dinheiro
      IMask(element, {
        mask: Number,
        thousandsSeparator: '.',
        padFractionalZeros: true,
        radix: ',',
        scale: 2,
        signed: false,
        normalizeZeros: true,
        disableNegative: true,
        min: 0
      });
    });

    // Máscara de Porcentagem
    const percentageMaskOptions = {
      mask: Number,
      scale: 2,
      radix: '.',
      normalizeZeros: false,
      padFractionalZeros: false,
      min: 0,
      max: 100,
      signed: true
    }

    this.percentageMaskTargets.forEach((element) => {
      IMask(element, percentageMaskOptions);
    });

    // Mascara de UF
    this.ufMaskTargets.forEach((element) => {
      IMask(element, {
        mask: /^[A-Za-z]{0,2}$/, // Aceita apenas letras, até 2 caracteres
        prepare: (str) => str.toUpperCase() // Converte para maiúsculas
      });
    });
  }
}
