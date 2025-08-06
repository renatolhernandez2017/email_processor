class ClosingsController < ApplicationController
  include Pagy::Backend
  include SharedData
  include PdfClassMapper

  before_action :set_closing, only: %i[update perform_closing modify_for_this_closure]
  before_action :set_banks, only: %i[deposits_in_banks download_pdf]

  def index
    @pagy, @closings = pagy(Closing.all.order(start_date: :desc))

    @closing = Closing.new
    closing = @closings.first

    return unless closing.present?

    @closing.start_date = closing.end_date + 1.day
    @closing.closing = (closing.end_date + 1.month).strftime("%b/%y")
  end

  def create
    @closing = Closing.new(closing_params)
    @current_closing.update(active: false)

    if @closing.save
      flash[:success] = "Fechamento criado com sucesso!"
      render turbo_stream: turbo_stream.action(:redirect, closings_path)
    else
      render turbo_stream: turbo_stream.replace("form_closing",
        partial: "closings/form", locals: {
          closing: @closing, title: "Novo fechamento", btn_save: "Salvar"
        })
    end
  end

  def update
    if @closing.update(closing_params)
      flash[:success] = "Fechamento atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, closings_path)
    else
      render turbo_stream: turbo_stream.replace("form_closing",
        partial: "closings/form", locals: {
          closing: @closing, title: "Novo fechamento", btn_save: "Salvar"
        })
    end
  end

  def perform_closing
    PerformClosingJob.perform_async(@closing.id)
  end

  def modify_for_this_closure
    return if @current_closing.id == @closing.id

    @current_closing.update(active: false)
    @closing.update(active: true)

    flash[:notice] = "O sistema está utilizando o fechamento de #{@closing.closing}!"

    render turbo_stream: turbo_stream.action(:redirect, root_path)
  end

  def note_divisions
    # Usa informações que vem do include RepresentativeSummaries
  end

  def deposits_in_banks
  end

  def closing_audit
    store_collection
    payment_for_representative
    as_follow
  end

  def payment_for_representative
    @payment_for_representatives = @current_closing&.payment_for_representatives(@current_closing&.id)
    @representative_total_quantity = @payment_for_representatives&.sum { |store| store[:quantity] }
    @representative_total_value = @payment_for_representatives&.sum { |store| store[:value] }
  end

  def store_collection
    @store_collections = @current_closing&.store_collections(@current_closing&.id)
    @store_total_count = @store_collections&.sum { |store| store[:count] }
    @store_total_value = @store_collections&.sum { |store| store[:total] }
  end

  def as_follow
    @as_follows = @current_closing&.as_follows(@current_closing&.id)
    @as_follow_total_count = @as_follows&.sum { |store| store[:count] }
    @as_follow_value = @as_follows&.sum { |store| store[:value] }
  end

  def download_pdf
    kind = params[:kind]
    current_month = closing_date(@current_closing)
    pdf_class = PDF_CLASSES[kind]
    pdf = pdf_class.new(@banks, current_month, @current_closing).render

    send_data pdf,
      filename: "#{kind}_#{current_month.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
  end

  private

  def closing_params
    params.require(:closing).permit(
      :active,
      :start_date,
      :end_date,
      :closing,
      :last_envelope
    )
  end

  def set_closing
    @closing = Closing.find_by(id: params[:id])
  end

  def closing_date(closing)
    month_abbr = closing.closing.split("/")
    "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"
  end

  def set_banks
    @banks = Closing.set_current_accounts(@current_closing&.id)
  end
end
