class ImportCsvService
  def initialize(file_path)
    @file_path = file_path
    @kind = identify_type(file_path)
  end

  def import!
    case @kind
    when :fc01000
      Importers::Fc01000.new(@file_path).import!
    when :fc08000
      Importers::Fc08000.new(@file_path).import!
    when :fc12100
      Importers::Fc12100.new(@file_path).import!
    when :fc17100
      Importers::Fc17100.new(@file_path).import!
    when :fc17000
      Importers::Fc17000.new(@file_path).import!
    when :fc04000
      Importers::Fc04000.new(@file_path).import!
    else
      raise "Tipo de importação não suportado: #{@file_path}"
    end
  end

  private

  def identify_type(file_path)
    case File.basename(file_path)
    when /fc01000/i then :fc01000
    when /fc08000/i then :fc08000
    when /fc12100/i then :fc12100
    when /fc17100/i then :fc17100
    when /fc17000/i then :fc17000
    when /fc04000/i then :fc04000
    else :unknown
    end
  end
end
