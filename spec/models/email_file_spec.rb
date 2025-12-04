require "rails_helper"

RSpec.describe EmailFile, type: :model do
  describe "associations" do
    it { should have_many(:processing_logs).dependent(:destroy) }
  end

  describe "validations" do
    it "é válido com filename e path" do
      email_file = EmailFile.new(filename: "arquivo.eml", path: "/tmp/arquivo.eml")
      expect(email_file).to be_valid
    end

    it "é inválido sem filename" do
      email_file = EmailFile.new(filename: nil, path: "/tmp/x")

      expect(email_file).not_to be_valid
      expect(email_file.errors[:filename]).to include("não pode ficar em branco")
    end

    it "é inválido sem path" do
      email_file = EmailFile.new(filename: "arquivo.eml", path: nil)

      expect(email_file).not_to be_valid
      expect(email_file.errors[:path]).to include("não pode ficar em branco")
    end
  end
end
