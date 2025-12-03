class EmailProcessor
  PARSERS = {
    /fornecedorA@example.com/i => 'Parsers::SupplierAParser',
    /parceiroB@example.com/i => 'Parsers::PartnerBParser'
  }

  def initialize(email_file)
    @email_file = email_file
    @mail = Mail.read_from_string(email_file.raw)
  end

  def process!
    parser_class = select_parser

    unless parser_class
      log_failure("No parser for sender: #{@mail.from}")
      return false
    end

    parser = parser_class.constantize.new(@mail)
    result = parser.call

    if valid_result?(result)
      create_customer(result)
      log_success(result)
      true
    else
      log_failure("Missing contact info", result)
      false
    end
  rescue => e
    log_failure(e.message)
    false
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
    Customer.create!(
      name: res[:name],
      email: res[:email],
      phone: res[:phone],
      product_code: res[:product_code],
      source: @mail.from&.first
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
