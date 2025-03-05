class PersonsController < ApplicationController
  include Pagy::Backend

  before_action :get_person, only: %i[update show]

  def index
    @pagy, @people = pagy(Person.all.order(created_at: :desc))

    @person = Person.new
  end

  def create
    @person = Person.new(person_params)

    if @person.save
      flash[:success] = "Representante foi criado com sucesso!"
      render turbo_stream: turbo_stream.action(:redirect, persons_path)
    else
      render turbo_stream: turbo_stream.replace("form_person", partial: "persons/form", locals: {person: @person, title: "Novo fechamento", btn_save: "Salvar"})
    end
  end

  def update
    if @person.update(person_params)
      flash[:success] = "Representante foi atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, persons_path)
    else
      render turbo_stream: turbo_stream.replace("form_person", partial: "persons/form", locals: {person: @person, title: "Novo fechamento", btn_save: "Salvar"})
    end
  end

  def show
  end

  private

  def person_params
    params.require(:person).permit(
      :kind,
      :name,
      :cnpj,
      :rg,
      :representative_number,
      :class_concil,
      :uf_concil,
      :number_concil,
      :birthdate,
      :cpf
    )
  end

  def get_person
    @person = Person.find(params[:id])
  end
end
