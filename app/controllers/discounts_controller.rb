class DiscountsController < ApplicationController
  include Pagy::Backend
  include Redirectable

  before_action :get_branches
  before_action :get_discount, only: %i[update destroy]

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
          branches: @branches, btn_save: "Salvar"
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
          branches: @branches, btn_save: "Atualizar"
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

  def get_discount
    @discount = Discount.find(params[:id])
  end

  def get_branches
    @branches = Branch.all.map { |branch| [branch.name, branch.id] }
  end
end
