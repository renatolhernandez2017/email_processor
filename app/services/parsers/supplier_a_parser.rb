module Parsers
  class SupplierAParser < Base
    def call
      {
        name: extract_by_regex(/Nome:\s*(.+)/i),
        email: extract_by_regex(/E-?mail:\s*([\w.+-]+@[\w.-]+)/i),
        phone: extract_by_regex(/Telefone:\s*([\d\-\s\(\)\+]+)/i),
        product_code: extract_by_regex(/Código do Produto:\s*(\w+)/i),
        subject: extract_by_regex(/Assunto:\s*(\w+)/i)
      }
    end
  end
end
