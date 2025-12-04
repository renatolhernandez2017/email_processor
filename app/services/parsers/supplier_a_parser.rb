module Parsers
  class SupplierAParser < Base
    def call
      {
        name: extract_by_regex(/Nome:\s*(.+)/i) || extract_by_regex(/Nome do cliente:\s*(.+)/i) || extract_by_regex(/Nome completo:\s*(.+)/i) || extract_by_regex(/Cliente:\s*(.+)/i),
        email: extract_by_regex(/E-mail:\s*([\w.+-]+@[\w.-]+)/i) || extract_by_regex(/Email:\s*([\w.+-]+@[\w.-]+)/i) || extract_by_regex(/Email de contato:\s*([\w.+-]+@[\w.-]+)/i),
        phone: extract_by_regex(/Telefone:\s*([\d\-\s\(\)\+]+)/i),
        product_code: extract_by_regex(/c[oó]digo\s*([A-Z0-9]+)/i) || extract_by_regex(/produto\s+abc123/i) || extract_by_regex(/Produto de interesse:\s*(.+)/i) || extract_by_regex(/Produto do produto:\s*(.+)/i),
        subject: extract_by_regex(/Subject:\s*(\w+)/i),
        kind: 'supplier'
      }
    end
  end
end
