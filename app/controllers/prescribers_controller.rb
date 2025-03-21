class PrescribersController < ApplicationController
  include Pagy::Backend

  before_action :get_representatives, :get_prescribers
  before_action :get_prescriber, only: %i[update destroy]

  def index
    @pagy, @prescribers = pagy(@prescribers_map.order(created_at: :desc))

    @current_account = CurrentAccount.new
    @current_account.build_bank
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

  def destroy
    @prescriber.destroy

    flash[:success] = "Prescritor apagado com sucesso."
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
      :representative_id,
      address_attributes: %i[
        street district number complement city uf zip_code phone cellphone fax
        representative_id prescriber_id
      ]
    )
  end

  def get_prescriber
    @prescriber = Prescriber.find(params[:id])
  end

  def get_representatives
    @representatives = Representative.all
  end

  def get_prescribers
    @prescribers_map = Prescriber.all
  end
end
