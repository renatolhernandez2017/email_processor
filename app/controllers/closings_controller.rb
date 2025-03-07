class ClosingsController < ApplicationController
  include Pagy::Backend

  before_action :get_closing, only: %i[update destroy modify_for_this_closure]

  def index
    @pagy, @closings = pagy(Closing.all.order(start_date: :desc))

    @closing = Closing.new
    closing = @closings.first
    @closing.start_date = closing.end_date + 1.day
    @closing.closing = (closing.end_date + 1.month).strftime("%b/%y")
  end

  def create
    @closing = Closing.new(closing_params)

    if @closing.save
      flash[:success] = "Fechamento criado com sucesso!"
      render turbo_stream: turbo_stream.action(:redirect, closings_path)
    else
      render turbo_stream: turbo_stream.replace("form_closing", partial: "closings/form", locals: {closing: @closing, title: "Novo fechamento", btn_save: "Salvar"})
    end
  end

  def update
    if @closing.update(closing_params)
      flash[:success] = "Fechamento atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, closings_path)
    else
      render turbo_stream: turbo_stream.replace("form_closing", partial: "closings/form", locals: {closing: @closing, title: "Novo fechamento", btn_save: "Salvar"})
    end
  end

  def destroy
    @closing.destroy
    render turbo_stream: turbo_stream.action(:redirect, closings_path)
  end

  def modify_for_this_closure
    flash[:notice] = "O sistema está utilizando o fechamento de #{@closing.closing}!"

    @current_closing.update(active: false)
    @closing.update(active: true)

    render turbo_stream: turbo_stream.action(:redirect, closings_path)
  end

  private

  def closing_params
    params.require(:closing).permit(
      :start_date,
      :end_date,
      :closing,
      :last_envelope
    )
  end

  def get_closing
    @closing = Closing.find(params[:id])
  end
end
