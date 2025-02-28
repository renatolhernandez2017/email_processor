class ClosingsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @closings = pagy(Closing.all.order(start_date: :desc))

    @closing = Closing.new
    closing = @closings.first
    @closing.start_date = closing.end_date + 1.day
    @closing.closing = (closing.end_date + 1.month).strftime("%b/%y")
  end

  def show
    @closing = Closing.find(params[:id])
  end

  def create
    @closing = Closing.new(closing_params)

    if @closing.save
      flash[:success] = "Fechamento foi criado com sucesso!"
      render turbo_stream: turbo_stream.action(:redirect, closings_path)
    else
      render turbo_stream: turbo_stream.replace("form_new_closing", partial: "closings/form", locals: {closing: @closing, title: "Novo fechamento"})
    end
  end

  def update
    @closing = Closing.find(params[:id])

    if @closing.update_attributes(closing_params)
      flash[:success] = "Fechamento foi atualizado com sucesso."
      redirect_to closing_path(@closing)
    else
      render action: "edit"
    end
  end

  def destroy
    Closing.find(params[:id]).destroy
    redirect_to closings_path
  end

  def modify_for_this_closure
    @closing = Closing.find(params[:id])

    flash[:notice] = "O sistema está utilizando o fechamento de #{@closing.closing}!"
    redirect_to closings_path
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
end
