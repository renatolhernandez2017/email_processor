class RepresentativesController < ApplicationController
  include Pagy::Backend
  include Roundable
  include SharedData
  include PdfClassMapper

  before_action :set_selects_label
  before_action :set_representative, only: %i[update change_active]
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
  end

  def patient_listing
    @representatives = Representative.with_totals(@current_closing.id).where(id: params[:id])
  end

  def summary_patient_listing
    @representatives = Representative.with_totals(@current_closing.id).where(id: params[:id])
  end

  def select
    @select_action = params[:select_action]
    @title = @select.find { |select| select if select.include?(@select_action) }.first
    @representatives = Representative.with_totals(@current_closing.id)

    if @title == "Listagem de Pacientes" || @title == "Listagem de Pacientes Resumida" || @title == "Relatório de Endereços" || @title == "Etiquetas"
      load_prescribers_for_representatives
    else
      load_totals_for_representatives
    end
  end

  def unaccumulated_addresses
    @representatives = Representative.with_totals(@current_closing.id).where(id: params[:id])
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
    pdf = pdf_class.new(@representatives, @current_closing, params[:kind]).render

    send_data pdf,
      filename: "#{pdf_class}_#{@representatives[0].name.parameterize}_#{@current_closing.closing.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
  end

  def download_select_pdf
    @representatives = Representative.with_totals(@current_closing.id)
    selected_key = @select.find { |action| action[0] == params[:kind] }&.last
    pdf_class = PDF_CLASSES[selected_key]
    pdf = pdf_class.new(@representatives, @current_closing, selected_key).render

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
      ["Listagem de Pacientes", "patient_listing"],
      ["Listagem de Pacientes Resumida", "summary_patient_listing"],
      ["Resumido Mensal", "monthly_summary"],
      ["Etiquetas", "tags"],
      ["Relatório de Endereços", "address_report"]
    ]
  end

  def load_prescribers_for_representatives
    @prescribers = []

    @representatives.each do |representative|
      @prescribers[representative.id] = Prescriber.with_totals(@current_closing.id, representative.id)
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
      @prescribers[representative.id] = Prescriber.with_totals(@current_closing.id, representative.id)

      prescriber = @prescribers[representative.id].first
      @totals[representative.id] = Prescriber.get_totals(prescriber)

      @totals_by_bank[representative.id] = Prescriber.totals_by_bank_for_representatives(@current_closing.id, representative.id)
      totals_from_banks = @totals_by_bank[representative.id].first
      @totals_from_banks[representative.id] = Prescriber.totals_by_bank_store(totals_from_banks)

      @totals_by_store[representative.id] = Prescriber.totals_by_store_for_representatives(@current_closing.id, representative.id)
      totals_from_stores = @totals_by_store[representative.id].first
      @totals_from_stores[representative.id] = Prescriber.totals_by_bank_store(totals_from_stores)

      available_value = @totals[representative.id][:real_sale][:available_value].to_f
      @total_in_cash[representative.id] = divide_into_notes(available_value)
    end
  end
end
