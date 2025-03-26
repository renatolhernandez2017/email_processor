class PrescribersController < ApplicationController
  include Pagy::Backend

  before_action :set_representatives
  before_action :set_prescribers
  before_action :set_branches
  before_action :set_prescriber, only: %i[update show destroy desaccumulate]

  def index
    @pagy, @prescribers = pagy(@prescribers_map.order(created_at: :desc))

    @current_account = CurrentAccount.new
    @current_account.build_bank
    @discount = Discount.new
    @prescribers.each(&:ensure_address)
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
    closing_id = @current_closing.id
    @address = @prescriber.address
    @current_accounts = @prescriber.current_accounts

    @discounts = @prescriber&.discounts
      &.joins(:monthly_report)
      &.where(monthly_reports: {closing_id: closing_id})
  end

  def destroy
    @prescriber.destroy

    flash[:success] = "Prescritor apagado com sucesso."
    render turbo_stream: turbo_stream.action(:redirect, prescribers_path)
  end

  def desaccumulate
    # @prescriber
    # @current_closin

    # usar nos params abaixo se precisar
    # monthly_reports_attributes: %i[
    #   id month year value
    # ]
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

  def set_representatives
    @representatives = Representative.all
  end

  def set_prescribers
    @prescribers_map = Prescriber.all
  end

  def set_branches
    @branches = Branch.pluck(:name, :id)
  end
end
