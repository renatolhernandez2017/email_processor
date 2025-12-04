require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "validations" do

    it "é inválido sem name" do
      customer = Customer.new(name: nil, email: "test@example.com", phone: "11999999999")

      expect(customer).not_to be_valid
      expect(customer.errors[:name]).to include("não pode ficar em branco")
    end

    it "é inválido sem email" do
      customer = Customer.new(name: "Renato", email: nil, phone: "11999999999")

      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("não pode ficar em branco")
    end

    it "é inválido sem phone" do
      customer = Customer.new(name: "Renato", email: "test@example.com", phone: nil)

      expect(customer).not_to be_valid
      expect(customer.errors[:phone]).to include("não pode ficar em branco")
    end

    it "é inválido sem email e phone" do
      customer = Customer.new(name: "Renato")

      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("não pode ficar em branco")
      expect(customer.errors[:phone]).to include("não pode ficar em branco")
    end

    it "é inválido com email vazio mesmo se phone estiver preenchido" do
      customer = Customer.new(name: "Renato", email: "", phone: "11999999999")

      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("não pode ficar em branco")
    end

    it "é inválido com phone vazio mesmo se email estiver preenchido" do
      customer = Customer.new(name: "Renato", email: "test@example.com", phone: "")

      expect(customer).not_to be_valid
      expect(customer.errors[:phone]).to include("não pode ficar em branco")
    end

    it "é válido com name, email e phone completos" do
      customer = Customer.new(name: "Renato", email: "test@example.com", phone: "11999999999")

      expect(customer).to be_valid
    end
  end
end
