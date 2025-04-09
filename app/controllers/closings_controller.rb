class ClosingsController < ApplicationController
  include Pagy::Backend

  before_action :set_closing, only: %i[update modify_for_this_closure]

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
      render turbo_stream: turbo_stream.replace("form_closing",
        partial: "closings/form", locals: {
          closing: @closing, title: "Novo fechamento", btn_save: "Salvar"
        })
    end
  end

  def update
    if @closing.update(closing_params)
      flash[:success] = "Fechamento atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, closings_path)
    else
      render turbo_stream: turbo_stream.replace("form_closing",
        partial: "closings/form", locals: {
          closing: @closing, title: "Novo fechamento", btn_save: "Salvar"
        })
    end
  end

  def modify_for_this_closure
    return if @current_closing.id == @closing.id

    @current_closing.update(active: false)
    @closing.update(active: true)

    flash[:notice] = "O sistema está utilizando o fechamento de #{@closing.closing}!"

    render turbo_stream: turbo_stream.action(:redirect, root_path)
  end

  def note_divisions
    calculator = NoteDivisionCalculator.new(@current_closing.id).call

    @note_divisions = calculator.note_divisions
    @total_marks = calculator.total_marks
    @total_cash = calculator.total_cash
  end

  def deposits_in_banks
    @banks = @current_closing.set_current_accounts(@current_closing.id)
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

  def set_closing
    @closing = Closing.find_by(id: params[:id])
  end
end
