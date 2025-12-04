require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "validations" do
    
    it "é inválido sem name" do
      customer = Customer.new(name: nil, email: "test@example.com")
      expect(customer).not_to be_valid
      expect(customer.errors[:name]).to include("não pode ficar em branco")
    end

    it "é válido com name e email" do
      customer = Customer.new(name: "Renato", email: "test@example.com")
      expect(customer).to be_valid
    end

    it "é válido com name e phone" do
      customer = Customer.new(name: "Renato", phone: "11999999999")
      expect(customer).to be_valid
    end

    it "é inválido sem email e sem phone" do
      customer = Customer.new(name: "Renato")

      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("não pode ficar em branco")
      expect(customer.errors[:phone]).to include("não pode ficar em branco")
    end

    it "é inválido com email vazio mesmo se phone estiver vazio" do
      customer = Customer.new(name: "Renato", email: "", phone: "")
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("não pode ficar em branco")
      expect(customer.errors[:phone]).to include("não pode ficar em branco")
    end

    it "é válido com phone mesmo que email seja vazio" do
      customer = Customer.new(name: "Renato", email: "", phone: "11999999999")
      expect(customer).to be_valid
    end

    it "é válido com email mesmo que phone seja vazio" do
      customer = Customer.new(name: "Renato", email: "test@example.com", phone: "")
      expect(customer).to be_valid
    end
  end
end
