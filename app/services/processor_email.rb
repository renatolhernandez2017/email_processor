class ProcessorEmail
  PARSERS = {
    /fornecedorA@gmail.com/i => 'Parsers::SupplierAParser',
    /parceiroB@gmail.com/i => 'Parsers::PartnerBParser'
  }

  def initialize(email_file, mail_object = nil)
    @mail = mail_object || Mail.read_from_string(email_file.raw)
    @email_file = email_file
  end

  def process!
    broadcast_step("Arquivo recebido", false, 1)
    sleep(2)

    parser_class = select_parser

    unless parser_class
      log_failure("No parser for sender: #{@mail.from}")
      return false
    end

    broadcast_step("Lendo arquivo", false, 2)
    sleep(2)

    parser = parser_class.constantize.new(@mail)
    result = parser.call

    if valid_result?(result)
      broadcast_step("Criando customers", false, 3)
      sleep(2)
      create_customer(result)

      broadcast_step("Criando logs", false, 4)
      sleep(2)
      log_success(result)

      broadcast_step("Concluído", true, 5)
      sleep(2)
      true
    else
      log_failure("Missing contact info", result)
      broadcast_step("Concluído", true, 5)
      sleep(2)
      false
    end
  rescue => e
    log = log_failure(e.message)
    broadcast_step("Error: #{log}", true, 6)
    sleep(2)
    false
  end

  def broadcast_step(message, status, step)
    EmailChannel.broadcast_to("email", {message: message, status: status, step: step})
  end

  private

  def select_parser
    sender = @mail.from&.first.to_s
    entry = PARSERS.find { |re, _| sender =~ re }
    entry && entry.last
  end

  def valid_result?(res)
    return false unless res.is_a?(Hash)
    res[:email].present? || res[:phone].present?
  end

  def create_customer(res)
    customer = Customer.find_or_create_by(email: res[:email], product_code: res[:product_code])

    customer.update(
      name: res[:name],
      phone: res[:phone],
      source: @mail.from&.first,
      kind: res[:kind]
    )
  end

  def log_success(res)
    ProcessingLog.create!(email_file: @email_file, success: true, extracted_data: res)
    @email_file.update!(status: 'processed')
  end

  def log_failure(msg, res = nil)
    ProcessingLog.create!(email_file: @email_file, success: false, extracted_data: (res || {}), error_message: msg)
    @email_file.update!(status: 'failed')
  end
end
