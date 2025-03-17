class PrescribersController < ApplicationController
  include Pagy::Backend

  before_action :get_representatives
  before_action :get_prescriber, only: %i[update]

  def index
    @pagy, @prescribers = pagy(Prescriber.all.order(created_at: :desc))
  end

  def update
    update_address

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

  private

  def prescriber_params
    params.require(:prescriber).permit(
      :name,
      :council,
      :partnership,
      :secretary,
      :note,
      :consider_discount_of_up_to,
      :percentage_ciscount,
      :repetitions,
      :allows_changes_values,
      :discount_value,
      :class_council,
      :number_council,
      :uf_council,
      :birthdate,
      :representative_id
    )
  end

  def get_prescriber
    @prescriber = Prescriber.find(params[:id])
  end

  def get_representatives
    @representatives = Representative.all.map do |representative|
      [representative.name, representative.id, {
        "data-id": representative.id,
        "data-address": representative.address.street,
        "data-district": representative.address.district,
        "data-number": representative.address.number,
        "data-complement": representative.address.complement,
        "data-city": representative.address.city,
        "data-uf": representative.address.uf,
        "data-zip": representative.address.zip_code,
        "data-phone": representative.address.phone,
        "data-cellphone": representative.address.cellphone,
        "data-fax": representative.address.fax
      }]
    end
  end

  def update_address
    return unless params["prescriber"]["representative_id"] == params["prescriber"]["representative_attributes"]["id"]

    if params.dig("prescriber", "representative_attributes", "address_attributes").present?
      address_params = params["prescriber"]["representative_attributes"]["address_attributes"]

      address = {
        street: address_params["street"],
        district: address_params["district"],
        number: address_params["number"],
        complement: address_params["complement"],
        city: address_params["city"],
        uf: address_params["uf"],
        zip_code: address_params["zip_code"],
        phone: address_params["phone"],
        cellphone: address_params["cellphone"],
        fax: address_params["fax"]
      }

      @prescriber.representative.address.update(address) if address.present?
    end
  end
end
