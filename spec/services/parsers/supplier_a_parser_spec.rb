require 'rails_helper'

RSpec.describe Parsers::SupplierAParser do
  let(:body_text) do
    <<~TEXT
      Nome: Maria Oliveira
      E-mail: maria.oliveira@example.com
      Telefone: +55 (21) 98888-7777
      Código do Produto: PROD567
      Assunto: Pedido
    TEXT
  end

  let(:mail) do
    double("Mail", body: double("Body", decoded: body_text))
  end

  subject { described_class.new(mail) }

  describe "#call" do
    it "returns a hash with parsed fields" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result[:name]).to eq("Maria Oliveira")
      expect(result[:email]).to eq("maria.oliveira@example.com")
      expect(result[:phone]).to eq("+55 (21) 98888-7777")
      expect(result[:product_code]).to eq("PROD567")
      expect(result[:subject]).to eq("Pedido")
      expect(result[:kind]).to eq("supplier")
    end

    it "returns nil for fields not found" do
      mail_missing = double("Mail", body: double("Body", decoded: "Nome: Maria"))
      parser = described_class.new(mail_missing)

      result = parser.call

      expect(result[:email]).to be_nil
      expect(result[:phone]).to be_nil
      expect(result[:product_code]).to be_nil
      expect(result[:subject]).to be_nil
    end
  end
end
