class PrescribersController < ApplicationController
  include Pagy::Backend
  include SharedData

  before_action :set_closing_date, only: %i[patient_listing]
  before_action :set_prescribers
  before_action :set_prescriber, except: %i[index]

  def index
    @pagy, @prescribers = pagy(@prescribers_map.order(created_at: :desc))

    @current_account = CurrentAccount.new
    @current_account.build_bank
    @discount = Discount.new
    @prescribers.each(&:ensure_address)
    @requests = Request.set_requests(@prescribers, @current_closing.id)
  end

  def update
    if @prescriber.update(prescriber_params)
      flash[:success] = "Prescritor atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, prescribers_path)
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

    @discounts = @prescriber.discounts
      .includes(prescriber: :monthly_reports)
      .where(monthly_reports: {closing_id: @current_closing.id}, visible: true)
  end

  def destroy
    @prescriber.destroy

    flash[:success] = "Prescritor apagado com sucesso."
    render turbo_stream: turbo_stream.action(:redirect, prescribers_path)
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

    render turbo_stream: turbo_stream.action(:redirect, prescribers_path)
  end

  def patient_listing
    @representative = @prescriber.representative
    @monthly_reports = @prescriber.monthly_reports_false(@current_closing.id, [:prescriber])
      .group_by { |report| [report.envelope_number, report.situation] }
      .map do |info, reports|
        {
          info: info,
          reports: reports
        }
      end
  end

  def requests
    @requests = Request.set_requests_params(params.dig(:prescriber, :requests_attributes))

    @requests.each do |request|
      Request.find(request[:id]).update(request)
    end

    flash[:success] = "Valores alterados com sucesso!"
    render turbo_stream: turbo_stream.action(:redirect, prescribers_path)
  end

  private

  def prescriber_params
    params.require(:prescriber).permit(
      :name,
      :council,
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
      :crm,
      :representative_number,
      :representative_id,
      address_attributes: %i[
        street district number complement city uf zip_code phone cellphone fax
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

  def set_closing_date
    month_abbr = @current_closing.closing.split("/")
    @closing = "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"
  end
end
