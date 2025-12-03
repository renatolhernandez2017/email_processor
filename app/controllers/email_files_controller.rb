class EmailFilesController < ApplicationController
  include Pagy::Backend

  def upload
    quebrar
  end

  def process_file
    if params[:files][1].blank?
      redirect_to root_path, alert: "Selecione arquivos .eml"
      return
    end

    files = params[:files][1..-1]

    files.each do |file|
      stored_path = Rails.root.join("storage", "eml", file.original_filename)
      FileUtils.mkdir_p(File.dirname(stored_path))

      File.open(stored_path, "wb") do |f|
        f.write(file.read)
      end

      email = create_email_file(stored_path, file.original_filename)

      # Envia para processamento async
      EmailProcessorWorker.perform_async(email.id)
    end

    # p "0202" * 50
    # p params[:files][1..-1]
    # p "0202" * 50
    # quebrar 4

    redirect_to root_path, notice: "Arquivo enviado! O processamento será executado em background."
  end

  def create_email_file(stored_path, filename)
    EmailFile.find_or_create_by(path: stored_path.to_s) do |ef|
      ef.filename = filename,
      ef.raw = File.read(stored_path)
      ef.status = "pending"
    end
  end
end
