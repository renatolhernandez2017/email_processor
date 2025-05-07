class RepresentativesController < ApplicationController
  include Pagy::Backend
  include Roundable
  include SharedData
  include RepresentativeSummaries

  before_action :set_selects_label
  before_action :set_closing_date, except: %i[index update change_active]
  before_action :set_representative, except: %i[index]

  def index
    @pagy, @representatives = pagy(Representative.all.order(created_at: :desc))

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
    @summary = @representative.monthly_reports_load(@representative, @current_closing.id)
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
  end

  def unaccumulated_addresses
    @monthly_reports = @representative.monthly_reports_false(@current_closing.id, [{representative: [:address, :prescriber]}])
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
    case params[:kind]
    when "monthly_report"
      pdf = Pdfs::MonthlyReport.new(@representative, @closing, @current_closing).render
    when "patient_listing"
      pdf = Pdfs::PatientListing.new(@representative, @closing, @current_closing.id).render
    when "summary_patient_listing"
      pdf = Pdfs::SummaryPatientListing.new(@representative, @closing, @current_closing.id).render
    when "unaccumulated_addresses"
      pdf = Pdfs::UnaccumulatedAddresses.new(@representative, @closing, @current_closing).render
    end

    send_data pdf,
      filename: "resumo_#{@representative.name.parameterize}_#{@closing.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
  end

  def download_select_pdf
    selected_action = @select.find { |action| action[0] == params[:kind] }&.last

    case selected_action
    when "save_patient_listing"
      @pdf = Pdfs::SavePatientListing.new(@representatives, @closing, @current_closing.id).render
    when "saves_summary_patient_listing"
      @pdf = Pdfs::SavesSummaryPatientListing.new(@representatives, @closing, @current_closing.id).render
    when "monthly_summary"
      @pdf = Pdfs::MonthlySummary.new(@representatives, @closing, @current_closing.id).render
    when "tags"
      #   pdf = Pdfs::Tags.new(@representative, @closing, @current_closing).render
    when "address_report"
      # pdf = Pdfs::AddressReport.new(@representative, @closing, @current_closing).render
    end

    send_data @pdf,
      filename: "resumo_#{@closing.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
  end

  private

  def representative_params
    params.require(:representative).permit(
      :name,
      :partnership,
      :performs_closing,
      :active,
      :branch_id
    )
  end

  def set_representative
    @representative = Representative.find_by(id: params[:id])
  end

  def set_closing_date
    month_abbr = @current_closing.closing.split("/")
    @closing = "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"
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
