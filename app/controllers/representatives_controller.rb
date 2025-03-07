class RepresentativesController < ApplicationController
  include Pagy::Backend

  before_action :get_branches
  before_action :get_representative, only: %i[update show]

  def index
    @pagy, @representatives = pagy(Representative.all.order(created_at: :desc))

    @representative = Representative.new
  end

  def create
    @representative = Representative.new(representative_params)

    if @representative.save
      flash[:success] = "Representante foi criado com sucesso!"
      render turbo_stream: turbo_stream.action(:redirect, representatives_path)
    else
      render turbo_stream: turbo_stream.replace("form_representative", partial: "representatives/form", locals: {representative: @representative, title: "Novo fechamento", btn_save: "Salvar"})
    end
  end

  def update
    if @representative.update(representative_params)
      flash[:success] = "Representante foi atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, representatives_path)
    else
      render turbo_stream: turbo_stream.replace("form_representative", partial: "representatives/form", locals: {representative: @representative, title: "Novo fechamento", btn_save: "Salvar"})
    end
  end
  
  def show
  end

  private

  def representative_params
    params.require(:representative).permit(
      :name,
      :partnership,
      :performs_closing
    )
  end

  def get_representative
    @representative = Representative.find(params[:id])
  end

  def get_branches
    @branches = Branch.all.map { |b| [b.name, b.id] }
  end
end
