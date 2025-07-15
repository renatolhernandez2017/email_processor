class RepresentativesController < ApplicationController
  include Pagy::Backend
  include Roundable
  include SharedData
  include PdfClassMapper

  before_action :set_selects_label
  before_action :set_closing_date, except: %i[index update change_active]
  before_action :set_representative, only: %i[update change_active]

  def index
    @pagy, @representatives = pagy(Representative.all.order(:number))

    @representative = Representative.new
    @current_account = CurrentAccount.new
    @current_account.build_bank
  end

  def update
    if @representative.update(representative_params)
      flash[:success] = "Representante atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, representatives_path)
    else
      render turbo_stream: turbo_stream.replace("form_representative",
        partial: "representatives/form", locals: {
          representative: @representative,
          branches: @branches,
          title: "Novo fechamento",
          btn_save: "Salvar"
        })
    end
  end

  def monthly_report
    @representatives = Representative.with_totals(@current_closing.id).where(id: params[:id])
    load_totals_for_representatives
  end

  def patient_listing
    @representatives = Representative.with_totals(@current_closing.id).where(id: params[:id])
    load_totals_for_representatives
  end

  def summary_patient_listing
    @representatives = Representative.with_totals(@current_closing.id).where(id: params[:id])
    load_totals_for_representatives
  end

  def select
    @select_action = params[:select_action]

    @title = @select.select { |action| action.is_a?(Array) && @select_action.include?(action[1]) }
      .map { |action| action[0] }.first

    @representatives = Representative.with_totals(@current_closing.id)
    load_totals_for_representatives
  end

  def unaccumulated_addresses
    @representatives = Representative.with_totals(@current_closing.id).where(id: params[:id])
    load_totals_for_representatives
  end

  def change_active
    case params[:type]
    when "active"
      @representative.update(active: true)

      flash[:info] = "Representante ativado com sucesso."
    when "desactive"
      @representative.update(active: false)

      flash[:info] = "Representante desativado com sucesso."
    end

    render turbo_stream: turbo_stream.action(:redirect, representatives_path)
  end

  def download_pdf
    @representatives = Representative.with_totals(@current_closing.id).where(id: params[:id])
    pdf_class = PDF_CLASSES[params[:kind]]
    pdf = pdf_class.new(@representatives, @closing, @current_closing).render

    send_data pdf,
      filename: "#{pdf_class}_#{@representatives[0].name.parameterize}_#{@closing.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
  end

  def download_select_pdf
    @representatives = Representative.with_totals(@current_closing.id)
    selected_key = @select.find { |action| action[0] == params[:kind] }&.last
    pdf_class = PDF_CLASSES[selected_key]
    pdf = pdf_class.new(@representatives, @closing, @current_closing).render

    send_data pdf,
      filename: "#{pdf_class}_#{@closing&.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  private

  def representative_params
    params.require(:representative).permit(
      :name,
      :partnership,
      :performs_closing,
      :active,
      :number,
      :branch_id
    )
  end

  def set_representative
    @representative = Representative.find_by(id: params[:id])
  end

  def set_closing_date
    month_abbr = @current_closing&.closing&.split("/")
    @closing = "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}" if month_abbr.present?
  end

  def set_selects_label
    @select = [
      ["Salva Listagem de Pacientes", "save_patient_listing"],
      ["Salva Listagem de Pacientes Resumida", "saves_summary_patient_listing"],
      ["Resumido Mensal", "monthly_summary"],
      ["Etiquetas", "tags"],
      ["Relatório de Endereços", "address_report"]
    ]
  end

  def load_totals_for_representatives
    @totals_by_bank = []
    @totals_by_store = []
    @total_in_cash = []
    @monthly_reports = []

    @representatives.each do |representative|
      @totals_by_bank[representative.id] = Representative.totals_by_bank_for_representatives(@current_closing.id, representative.id)
      @totals_by_store[representative.id] = Representative.totals_by_store_for_representatives(@current_closing.id, representative.id)
      total_cash = Representative.total_cash_for_representatives(@current_closing.id, representative.id)
      @total_in_cash[representative.id] = divide_into_notes(total_cash.sum(&:total_available_value).to_f)
      @monthly_reports[representative.id] = Representative.monthly_reports_for_representatives(@current_closing.id, representative.id)
    end
  end
end
