require 'rails_helper'

RSpec.describe ProcessorEmail do
  let(:email_file) { instance_double("EmailFile", raw: raw_email, update!: true) }
  let(:mail_object) { Mail.read_from_string(raw_email) }
  let(:raw_email) do
    <<~EMAIL
      From: loja@fornecedorA.com
      To: test@example.com
      Subject: Test
      Content-Type: text/plain

      Corpo do email
    EMAIL
  end

  before do
    # Evita atrasos nos testes
    allow_any_instance_of(ProcessorEmail).to receive(:sleep)

    # Mock do ActionCable
    allow(EmailChannel).to receive(:broadcast_to)

    # Mock do ProcessingLog
    allow(ProcessingLog).to receive(:create!)

    # Mock do Customer
    allow(Customer).to receive(:find_or_create_by).and_return(customer)
    allow(customer).to receive(:update)

    stub_const("Parsers::SupplierAParser", supplier_a_parser_class)
  end

  let(:supplier_a_parser_class) do
    Class.new do
      def initialize(mail); end
      def call; { email: "john@example.com", name: "John", phone: "123", product_code: "X1", kind: "vip" }; end
    end
  end

  let(:customer) { instance_double("Customer", update: true) }

  describe "#process!" do
    context "quando encontra um parser válido" do
      it "processa corretamente e retorna true" do
        service = described_class.new(email_file)

        expect(EmailChannel).to receive(:broadcast_to).at_least(:once)

        result = service.process!

        expect(result).to eq(true)

        expect(Customer).to have_received(:find_or_create_by).with(
          email: "john@example.com",
          product_code: "X1"
        )

        expect(ProcessingLog).to have_received(:create!).with(
          hash_including(success: true)
        )

        expect(email_file).to have_received(:update!).with(status: "processed")
      end
    end

    context "quando o parser retorna dados inválidos" do
      before do
        bad_parser = Class.new do
          def initialize(mail); end
          def call; { name: "John Doe" } # sem email ou phone
          end
        end
        stub_const("Parsers::SupplierAParser", bad_parser)
      end

      it "log_failure e retorna false" do
        service = described_class.new(email_file)

        expect(service.process!).to eq(false)

        expect(ProcessingLog).to have_received(:create!).with(
          hash_including(success: false, error_message: "Missing contact info")
        )

        expect(email_file).to have_received(:update!).with(status: "failed")
      end
    end

    context "quando o sender não tem parser" do
      let(:raw_email) do
        <<~EMAIL
          From: desconhecido@outro.com
          To: test@example.com
          Subject: Test
        EMAIL
      end

      it "não processa e retorna false" do
        service = described_class.new(email_file)

        expect(service.process!).to eq(false)

        expect(ProcessingLog).to have_received(:create!).with(
          hash_including(success: false, error_message: /No parser/)
        )

        expect(email_file).to have_received(:update!).with(status: "failed")
      end
    end

    context "quando ocorre uma exceção inesperada" do
      before do
        allow_any_instance_of(ProcessorEmail).to receive(:select_parser).and_raise("BOOM")
      end

      it "loga erro e retorna false" do
        service = described_class.new(email_file)

        expect(service.process!).to eq(false)

        expect(ProcessingLog).to have_received(:create!).with(
          hash_including(success: false, error_message: "BOOM")
        )

        expect(email_file).to have_received(:update!).with(status: "failed")
      end
    end
  end
end
