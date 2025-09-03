class ClosingsController < ApplicationController
  include Pagy::Backend
  include SharedData
  include PdfClassMapper
  include Roundable

  before_action :set_closing, only: %i[update perform_closing modify_for_this_closure]
  before_action :set_banks, only: %i[deposits_in_banks download_pdf]
  before_action :set_note_divisions, only: %i[note_divisions download_pdf]

  def index
    @pagy, @closings = pagy(Closing.all.order(start_date: :desc))

    if params[:query].present?
      @closings = @closings.search_global(params[:query])
    end

    @closing = Closing.new
    closing = @closings.first

    return unless closing.present?

    @closing.start_date = closing.end_date + 1.day
    end_date = closing.end_date + 1.month
    @closing.closing = I18n.t("date.month_names")[end_date.month].capitalize + end_date.strftime("/%y")
  end

  def create
    @closing = Closing.new(closing_params)
    @current_closing.update(active: false)

    if @closing.save
      flash[:success] = "Fechamento criado com sucesso!"
      turbo_redirect_back(fallback_location: closings_path)
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
      turbo_redirect_back(fallback_location: closings_path)
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

    turbo_redirect_back(fallback_location: root_path)
  end

  def note_divisions
  end

  def deposits_in_banks
  end

  def closing_audit
    store_collection
    payment_for_representative
    as_follow
  end

  def store_collection
    @store_collections = MonthlyReport.with_adjusted_billings(@current_closing&.id)
    @store_total_quantity = @store_collections.map { |branch_name, stores| stores.first.total_number_of_requests }.first
    @store_total_value = @store_collections.map { |branch_name, stores| stores.first.total_branch_partnership }.first
  end

  def payment_for_representative
    @payments = Closing.payment_for_representatives(@current_closing&.id)
    @total_quantity = @payments.map { |name, payment| payment.sum(&:total_quantity) }.first
    @total_value = @payments.map { |name, payment| payment.sum(&:total_available_value) }.first
  end

  def as_follow
    @as_follows = Closing.as_follows(@current_closing&.id)
    @as_follow_total_quantity = @as_follows.sum { |bank, as_follow| as_follow.sum(&:quantity) }
    @as_follow_total_value = @as_follows.sum { |bank, as_follow| as_follow.sum(&:available_value) }
  end

  def download_pdf
    kind = params[:kind]
    pdf_class = PDF_CLASSES[kind]
    pdf = pdf_class.new(@representatives, @banks, @current_closing).render

    send_data pdf,
      filename: "#{kind}_#{@current_closing.closing.downcase}.pdf",
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

  def set_banks
    @banks = Closing.set_current_accounts(@current_closing&.id)
  end

  def set_note_divisions
    @total_in_cash = []
    prescribers = []
    totals = []

    @representatives.each do |representative|
      prescribers_all = representative.prescribers.where(representative_id: representative.id)
      prescribers[representative.id] = prescribers_all.with_totals(@current_closing.id)
      prescriber = prescribers[representative.id].first
      totals[representative.id] = prescribers_all.get_totals(prescriber)
      available_value = totals[representative.id][:real_sale][:available_value].to_f
      @total_in_cash[representative.id] = divide_into_notes(available_value)
    end
  end
end
