module Parsers
  class Base
    def initialize(mail)
      @mail = mail
      @body = (mail.body.decoded rescue '')
    end

    # deve retornar Hash com keys: :name, :email, :phone, :product_code, :subject
    def call
      raise NotImplementedError
    end

    protected

    def extract_by_regex(regex)
      match = @body.match(regex)
      match && match[1]&.strip
    end
  end
end
