class ImportCsvService
  def initialize(file_path, closing_id = nil)
    @file_path = file_path
    @kind = identify_type(file_path)
    @closing_id = closing_id
  end

  def import!
    case @kind
    when :fc01000 then Importers::Fc01000.new(@file_path).import!
    when :fc08000 then Importers::Fc08000.new(@file_path).import!
    when :all then Importers::All.new(@file_path, @closing_id).import!
    else
      raise "Tipo de importação não suportado: #{@file_path}"
    end
  end

  private

  def identify_type(file_path)
    case File.basename(file_path)
    when /fc01000/i then :fc01000
    when /fc08000/i then :fc08000
    when /group_duplicates/i then :all
    else :unknown
    end
  end
end
