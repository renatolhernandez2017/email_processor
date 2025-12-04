require 'rails_helper'

RSpec.describe Parsers::Base do
  let(:mail) { double("Mail", body: double("Body", decoded: "Name: John Doe\nEmail: john@example.com")) }

  # Classe dummy para testar métodos protegidos e call
  class DummyParser < Parsers::Base
    public :extract_by_regex # tornar público apenas para teste
  end

  subject { DummyParser.new(mail) }

  describe "#initialize" do
    it "stores the mail" do
      expect(subject.instance_variable_get(:@mail)).to eq(mail)
    end

    it "decodes the mail body" do
      expect(subject.instance_variable_get(:@body)).to eq("Name: John Doe\nEmail: john@example.com")
    end
  end

  describe "#call" do
    it "raises NotImplementedError on the base class" do
      base = Parsers::Base.new(mail)
      expect { base.call }.to raise_error(NotImplementedError)
    end
  end

  describe "#extract_by_regex" do
    it "returns the first captured group stripped" do
      expect(subject.extract_by_regex(/Name:\s*(.+)/)).to eq("John Doe")
    end

    it "returns nil when there is no match" do
      expect(subject.extract_by_regex(/Phone:\s*(.+)/)).to be_nil
    end
  end
end
