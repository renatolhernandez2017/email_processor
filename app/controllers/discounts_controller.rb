class DiscountsController < ApplicationController
  include Pagy::Backend

  before_action :get_branches
  before_action :get_discount, only: %i[update]

  def index
    @pagy, @discounts = pagy(Discount.all.order(created_at: :desc))
  end

  def update
    if @discount.update(discount_params)
      flash[:success] = "Desconto atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, discounts_path)
    else
      render turbo_stream: turbo_stream.replace("form_discount",
        partial: "discounts/form", locals: {
          discount: @discount, title: "Editar Desconto : #{@discount.id}",
          branches: @branches, btn_save: "Atualizar"
        })
    end
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
