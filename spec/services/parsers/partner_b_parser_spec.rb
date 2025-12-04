require 'rails_helper'

RSpec.describe Parsers::PartnerBParser do
  let(:body_text) do
    <<~TEXT
      Cliente: João da Silva
      Email: joao.silva@example.com
      Telefone: (11) 99999-8888
      Produto de interesse: ABC123
      Subject: Suporte
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
      expect(result[:name]).to eq("João da Silva")
      expect(result[:email]).to eq("joao.silva@example.com")
      expect(result[:phone]).to eq("(11) 99999-8888")
      expect(result[:product_code]).to eq("ABC123")
      expect(result[:subject]).to eq("Suporte")
      expect(result[:kind]).to eq("partner")
    end

    it "returns nil for fields not found" do
      mail_missing = double("Mail", body: double("Body", decoded: "Cliente: João"))
      parser = described_class.new(mail_missing)

      result = parser.call

      expect(result[:email]).to be_nil
      expect(result[:phone]).to be_nil
      expect(result[:product_code]).to be_nil
      expect(result[:subject]).to be_nil
    end
  end
end
