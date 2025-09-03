class RepresentativesController < ApplicationController
  include Pagy::Backend
  include Roundable
  include SharedData
  include PdfClassMapper

  before_action :set_selects_label
  before_action :set_representative, only: %i[update change_active]
  before_action :set_representatives, only: %i[monthly_report patient_listing summary_patient_listing unaccumulated_addresses download_pdf]
  before_action :set_branches, only: %i[index update]
  before_action :load_totals_for_representatives, only: %i[monthly_report]
  before_action :load_prescribers_for_representatives, only: %i[patient_listing summary_patient_listing unaccumulated_addresses]

  def index
    @pagy, @representatives = pagy(Representative.all.order(:number))

    if params[:query].present?
      @representatives = @representatives.search_global(params[:query])
    end

    @representative = Representative.new
    @current_account = CurrentAccount.new
    @current_account.build_bank
  end

  def update
    if @representative.update(representative_params)
      flash[:success] = "Representante atualizado com sucesso."
      turbo_redirect_back(fallback_location: representatives_path)
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
  end

  def patient_listing
  end

  def summary_patient_listing
  end

  def select
    @select_action = params[:select_action]
    @title = @select.find { |select| select if select.include?(@select_action) }.first

    if @title == "Lista de Pacientes" || @title == "Lista de Pacientes Resumida" || @title == "Relatório de Endereços" || @title == "Etiquetas"
      load_prescribers_for_representatives
    else
      load_totals_for_representatives
    end
  end

  def unaccumulated_addresses
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

    turbo_redirect_back(fallback_location: representatives_path)
  end

  def download_pdf
    pdf_class = PDF_CLASSES[params[:kind]]
    pdf = pdf_class.new(@representatives, @current_closing, params[:kind], params[:filter]).render

    send_data pdf,
      filename: "#{pdf_class}_#{@representatives[0].name.parameterize}_#{@current_closing.closing.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
  end

  def download_select_pdf
    selected_key = @select.find { |action| action[0] == params[:kind] }&.last
    pdf_class = PDF_CLASSES[selected_key]
    pdf = pdf_class.new(@representatives, @current_closing, selected_key, params[:filter]).render

    send_data pdf,
      filename: "#{pdf_class}_#{@current_closing.closing.downcase}.pdf",
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

  def set_selects_label
    @select = [
      ["Lista de Pacientes", "patient_listing"],
      ["Lista de Pacientes Resumida", "summary_patient_listing"],
      ["Resumido Mensal", "monthly_summary"],
      ["Etiquetas", "tags"],
      ["Relatório de Endereços", "address_report"]
    ]
  end

  def set_representatives
    @representatives = @representatives.where(id: params[:id])
  end

  def set_branches
    @branches = Branch.pluck(:name, :branch_number, :id)
  end

  def load_prescribers_for_representatives
    @prescribers = []
    @requests = []

    @representatives.each do |representative|
      prescribers = representative.prescribers.where(representative_id: representative.id)
      @prescribers[representative.id] = prescribers.with_totals(@current_closing.id, params[:filter])

      @prescribers[representative.id].each do |prescriber|
        @requests[prescriber.id] = prescriber.requests.where(closing_id: @current_closing.id)
      end
    end
  end

  def load_totals_for_representatives
    @totals_by_bank = []
    @totals_by_store = []
    @total_in_cash = []
    @prescribers = []
    @totals = []
    @totals_from_banks = []
    @totals_from_stores = []

    @representatives.each do |representative|
      prescribers = representative.prescribers.where(representative_id: representative.id)
      @prescribers[representative.id] = prescribers.with_totals(@current_closing.id, params[:filter])

      prescriber = @prescribers[representative.id].first
      @totals[representative.id] = prescribers.get_totals(prescriber)

      @totals_by_bank[representative.id] = prescribers.totals_by_bank_for_representatives(@current_closing.id, params[:filter])
      @totals_from_banks[representative.id] = prescribers.totals_by_bank_store(@totals_by_bank[representative.id])

      @totals_by_store[representative.id] = prescribers.totals_by_store_for_representatives(@current_closing.id, params[:filter])
      @totals_from_stores[representative.id] = prescribers.totals_by_bank_store(@totals_by_store[representative.id])

      available_value = @totals[representative.id][:real_sale][:available_value].to_f.round
      @total_in_cash[representative.id] = divide_into_notes(available_value)
    end
  end
end
