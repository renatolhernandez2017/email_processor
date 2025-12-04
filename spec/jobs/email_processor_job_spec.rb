require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe EmailProcessorJob, type: :job do
  before do
    Sidekiq::Testing.fake!
  end

  let(:email_file) { instance_double("EmailFile") }

  describe "#perform" do
    it "chama ProcessorEmail com o email_file correto" do
      allow(EmailFile).to receive(:find).with(42).and_return(email_file)

      processor_instance = instance_double(ProcessorEmail, process!: true)
      allow(ProcessorEmail).to receive(:new).with(email_file).and_return(processor_instance)

      described_class.new.perform(42)

      expect(EmailFile).to have_received(:find).with(42)
      expect(ProcessorEmail).to have_received(:new).with(email_file)
      expect(processor_instance).to have_received(:process!)
    end

    it "não levanta erro caso ProcessorEmail retorne false" do
      allow(EmailFile).to receive(:find).with(10).and_return(email_file)

      processor_instance = instance_double(ProcessorEmail, process!: false)
      allow(ProcessorEmail).to receive(:new).with(email_file).and_return(processor_instance)

      expect { described_class.new.perform(10) }.not_to raise_error
    end

    it "propaga exceção se EmailFile não existir" do
      allow(EmailFile).to receive(:find).and_raise(ActiveRecord::RecordNotFound)

      expect {
        described_class.new.perform(999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".sidekiq_options" do
    it "usa a fila correta" do
      expect(described_class.get_sidekiq_options["queue"]).to eq(:email)
    end

    it "usa o lock until_executed" do
      expect(described_class.get_sidekiq_options["lock"]).to eq(:until_executed)
    end

    it "usa lock_args_method que retorna os args crus" do
      lam = described_class.get_sidekiq_options["lock_args_method"]
      expect(lam.call([777])).to eq([777])
    end
  end
end
