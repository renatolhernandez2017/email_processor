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

    function unformatMoney(value) {
      if (typeof value === 'string' && value) {
        // Remove os separadores de milhar (pontos) e substitui a vírgula decimal por ponto
        return value.replace(/\./g, '').replace(',', '.');
      }
      return value;
    }

    // Máscara de Dinheiro
    const moneyMaskOptions = {
      mask: Number,  // Define o tipo de máscara como Number
      thousandsSeparator: '.', // Separador de milhar
      padFractionalZeros: true, // Adiciona zeros fracionários
      radix: ',', // Separador decimal
      scale: 2, // Número de casas decimais
      signed: false, // Se o valor pode ser negativo
      normalizeZeros: true, // Normaliza os zeros
      disableNegative: true, // Desabilita valores negativos
      min: 0 // Valor mínimo
    }

    // Iterar sobre os campos alvo e aplicar a máscara
    this.moneyMaskTargets.forEach((element) => {
      let currentValue = element.value;

      // Se houver um valor atual (ex: na edição), desformatar e corrigir antes de aplicar a máscara
      if (currentValue) {
        let unformattedValue = unformatMoney(currentValue);
        
        // Garantir que o valor seja um número válido antes de aplicar a formatação
        if (!isNaN(unformattedValue)) {
          // Converte o valor desformatado para um número decimal e define o valor do campo
          element.value = parseFloat(unformattedValue).replace('.', ',');
        }
      }

      // Aplicar a máscara no campo (IMask irá gerenciar a exibição formatada)
      IMask(element, moneyMaskOptions);
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
