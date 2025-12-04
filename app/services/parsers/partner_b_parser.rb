module Parsers
  class PartnerBParser < Base
    def call
      {
        name: extract_by_regex(/Cliente:\s*(.+)/i),
        email: extract_by_regex(/Contato:\s*([\w.+-]+@[\w.-]+)/i),
        phone: extract_by_regex(/Celular:\s*([\d\-\s\(\)\+]+)/i),
        product_code: extract_by_regex(/Ref:\s*(\w+)/i),
        subject: extract_by_regex(/Assunto:\s*(\w+)/i),
        kind: 'partner'
      }
    end
  end
end
