class PrescribersController < ApplicationController
  include Pagy::Backend
  include SharedData
  include PdfClassMapper

  before_action :set_prescribers
  before_action :set_prescriber, except: %i[index]

  def index
    @pagy, @prescribers = pagy(@prescribers_map.order(:name))

    if params[:query].present?
      @prescribers = @prescribers.search_global(params[:query])
    end

    @current_account = CurrentAccount.new
    @current_account.build_bank

    @prescribers.each(&:ensure_address)
  end

  def update
    if @prescriber.update(prescriber_params)
      flash[:success] = "Prescritor atualizado com sucesso."
      turbo_redirect_back(fallback_location: prescribers_path)
    else
      render turbo_stream: turbo_stream.replace("form_prescriber",
        partial: "prescribers/form", locals: {
          prescriber: @prescriber,
          representatives: @representatives,
          title: "Editar Prescritor : #{@prescriber.id}",
          btn_save: "Atualizar"
        })
    end
  end

  def show
    @address = @prescriber.address
    @current_accounts = @prescriber.current_accounts
  end

  def destroy
    @prescriber.destroy

    flash[:success] = "Prescritor apagado com sucesso."
    turbo_redirect_back(fallback_location: prescribers_path)
  end

  def change_accumulated
    accumulated = @prescriber.to_boolean(params[:accumulated])

    @monthly_report = @current_closing.monthly_reports.where(
      prescriber_id: @prescriber.id, accumulated: accumulated
    ).first

    if @monthly_report.present?
      @monthly_report.update(accumulated: !accumulated)

      flash[:success] = "Prescritor desacumulado com sucesso!" if accumulated == true
      flash[:success] = "Prescritor acumulado com sucesso!" if accumulated == false
    else
      flash[:notice] = "Prescritor já desacumulado este mês." if accumulated == true
      flash[:notice] = "Prescritor já acumulado este mês." if accumulated == false
    end

    turbo_redirect_back(fallback_location: prescribers_path)
  end

  def patient_listing
    @requests = []
    @representative = @prescriber.representative
    prescribers = @representative.prescribers.where(representative_id: @representative.id)
    @prescribers = prescribers.with_totals(@current_closing.id).where(id: @prescriber.id)

    @prescribers.each do |prescriber|
      @requests[prescriber.id] = @prescriber.requests.where(closing_id: @current_closing.id).where.not(monthly_report_id: nil)
    end
  end

  def download_pdf
    pdf_class = PDF_CLASSES[params[:kind]]
    pdf = pdf_class.new(@prescriber, @current_closing).render

    send_data pdf,
      filename: "#{pdf_class}_#{@prescriber.name.parameterize}_#{@current_closing.closing.downcase}.pdf",
      type: "application/pdf",
      disposition: "inline" # ou "attachment" se quiser forçar download
  end

  private

  def prescriber_params
    params.require(:prescriber).permit(
      :name,
      :partnership,
      :secretary,
      :note,
      :consider_discount_of_up_to,
      :percentage_discount,
      :repetitions,
      :allows_changes_values,
      :discount_value,
      :class_council,
      :number_council,
      :uf_council,
      :birthdate,
      :representative_number,
      :representative_id,
      address_attributes: %i[
        street district number complement city uf zip_code phone cellphone
        representative_id prescriber_id _destroy
      ]
    )
  end

  def set_prescriber
    @prescriber = Prescriber.find_by(id: params[:id])
  end

  def set_prescribers
    @prescribers_map = Prescriber.all
  end
end
