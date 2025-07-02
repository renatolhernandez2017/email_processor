class RepresentativesController < ApplicationController
  include Pagy::Backend
  include Roundable
  include SharedData
  # include RepresentativeSummaries
  include PdfClassMapper

  before_action :set_selects_label
  before_action :set_closing_date, except: %i[index update change_active]
  before_action :set_representative, except: %i[index]

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
    monthly_reports = @representative.monthly_reports.joins(:prescriber)
      .where(closing_id: @current_closing.id)

    @summary = monthly_reports.order("prescribers.name ASC")
    @accumulated = monthly_reports.where(accumulated: true)

    @totals_by_bank = @representative.totals_by_bank(monthly_reports)
    @totals_by_store = @representative.totals_by_store(monthly_reports)
    @total_in_cash = @representative.total_cash(monthly_reports)
  end

  def patient_listing
    @monthly_reports = @representative.set_monthly_reports(@current_closing.id)
  end

  def summary_patient_listing
    @monthly_reports = @representative.set_monthly_reports(@current_closing.id)
  end

  def select
    @select_action = params[:select_action]

    @title = @select.select { |action| action.is_a?(Array) && @select_action.include?(action[1]) }
      .map { |action| action[0] }.first

    @summary = {}
    @accumulated = {}
    @totals_by_bank = {}
    @totals_by_store = {}
    @total_in_cash = {}

    @representatives = Representative.joins(:monthly_reports).where(active: true).distinct

    @representatives.each do |representative|
      monthly_reports = representative.monthly_reports.joins(:prescriber)
        .where(closing_id: @current_closing.id)

      @summary[representative.id] = monthly_reports
      @accumulated[representative.id] = monthly_reports.where(accumulated: true)

      @totals_by_bank[representative.id] = representative.totals_by_bank(monthly_reports)
      @totals_by_store[representative.id] = representative.totals_by_store(monthly_reports)
      @total_in_cash[representative.id] = representative.total_cash(monthly_reports)
    end
  end

  def unaccumulated_addresses
    @monthly_reports = @representative.get_monthly_reports(@current_closing.id)
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
    pdf_class = PDF_CLASSES[params[:kind]]
    pdf = pdf_class.new([@representative], @closing, @current_closing).render

    send_data pdf,
      filename: "#{pdf_class}_#{@representative.name.parameterize}_#{@closing.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
  end

  def download_select_pdf
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
end
