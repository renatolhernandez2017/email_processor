class EmailFilesController < ApplicationController
  include Pagy::Backend

  def process_file
    if params[:files][1].blank?
      flash[:alert] = "Selecione pelo menos 1 arquivo .eml"
      redirect_to root_path
      return
    end

    files = params[:files][1..-1]

    files.each do |file|
      stored_path = Rails.root.join("tmp", "eml", file.original_filename)
      FileUtils.mkdir_p(File.dirname(stored_path))

      File.open(stored_path, "wb") do |f|
        f.write(file.read)
      end

      email = create_email_file(stored_path, file.original_filename)

      # Envia para processamento async
      EmailProcessorJob.perform_async(email.id)
      sleep(5)
    end

    redirect_to root_path
  end

  def create_email_file(stored_path, filename)
    email_file = EmailFile.find_or_create_by(path: stored_path.to_s) do |ef|
      ef.filename = filename,
      ef.raw = File.read(stored_path)
      ef.status = "pending"
    end

    email_file
  end
end
