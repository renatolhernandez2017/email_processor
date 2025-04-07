class DiscountsController < ApplicationController
  include Pagy::Backend
  include Redirectable
  include SharedData

  before_action :set_discount, only: %i[update destroy]

  def index
    @pagy, @discounts = pagy(Discount.all.order(created_at: :desc))
  end

  def create
    @discount = Discount.new(discount_params)

    if @discount.save
      flash[:success] = "Desconto criado com sucesso."
      render_redirect
    else
      render turbo_stream: turbo_stream.replace("form_discount",
        partial: "discounts/form", locals: {
          discount: @discount, title: "Criar Desconto",
          prescriber: @discount.prescriber,
          branches: @branches, btn_save: "Salvar",
          route: "discount"
        })
    end
  end

  def update
    if @discount.update(discount_params)
      flash[:success] = "Desconto atualizado com sucesso."
      render_redirect
    else
      render turbo_stream: turbo_stream.replace("form_discount",
        partial: "discounts/form", locals: {
          discount: @discount, title: "Editar Desconto : #{@discount.id}",
          prescriber: @discount.prescriber,
          branches: @branches, btn_save: "Atualizar",
          route: @route
        })
    end
  end

  def destroy
    @discount.destroy

    flash[:success] = "Desconto apagado com sucesso."
    render_redirect
  end

  private

  def discount_params
    params_result = params.require(:discount).permit(
      :visible,
      :price,
      :description,
      :branch_id,
      :prescriber_id
    )

    params_result[:price] = params_result[:price].to_s.delete('/\./').tr("/,/", ".").to_f if params_result[:price].present?
    params_result
  end

  def set_discount
    @discount = Discount.find_by(id: params[:id])
  end
end
