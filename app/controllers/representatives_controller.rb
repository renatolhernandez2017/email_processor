class RepresentativesController < ApplicationController
  include Pagy::Backend
  include Roundable
  include SharedData

  before_action :set_closing_date, except: %i[index update]
  before_action :set_representative, except: %i[index]

  def index
    @pagy, @representatives = pagy(Representative.all.order(created_at: :desc))

    @representative = Representative.new
    @current_account = CurrentAccount.new
    @current_account.build_bank
  end

  def update
    if @representative.update(representative_params)
      flash[:success] = "Representante atualizado com sucesso."
      render turbo_stream: turbo_stream.action(:redirect, representatives_path)
    else
      render turbo_stream: turbo_stream.replace("form_representative",
        partial: "representatives/form", locals: {
          representative: @representative,
          branches: @branches,
          title: "Novo fechamento",
          btn_save: "Salvar"
        })
    end
  end

  def monthly_report
    @monthly_reports = @representative.load_monthly_reports(@current_closing.id, [{prescriber: {current_accounts: :bank}}])
    @accumulated = @monthly_reports.where(accumulated: true)

    calculate_totals_by_bank
    calculate_totals_by_store
    calculate_totals_note_division
  end

  def calculate_totals_by_bank
    @totals_by_bank = @representative.totals_by_bank(@current_closing.id)
    @total_count = @totals_by_bank.sum { |bank| bank[:count] }
    @total_value = @totals_by_bank.sum { |bank| bank[:total] }
  end

  def calculate_totals_by_store
    @totals_by_store = @representative.totals_by_store(@current_closing.id)
    @total_count_store = @totals_by_store.sum { |store| store[:count] }
    @total_store = @totals_by_store.sum { |store| store[:total] }
  end

  def calculate_totals_note_division
    @total_in_cash = @representative.total_cash(@current_closing.id)
    @total_marks = @total_in_cash.values.sum
    @total_cash = @total_in_cash.map { |key, value| key * value }.sum
  end

  def patient_listing
    load_monthly_reports_false
  end

  def summary_patient_listing
    load_monthly_reports_false
  end

  def unaccumulated_addresses
    @monthly_reports = @representative.load_monthly_reports(@current_closing.id, [{representative: [:address, :prescriber]}])
  end

  private

  def load_monthly_reports_false
    @monthly_reports = @representative.monthly_reports_false(@current_closing.id, [:requests, {representative: :prescriber}])
  end

  def representative_params
    params.require(:representative).permit(
      :name,
      :partnership,
      :performs_closing,
      :branch_id
    )
  end

  def set_representative
    @representative = Representative.find_by(id: params[:id])
  end

  def set_closing_date
    month_abbr = @current_closing.closing.split("/")
    @closing = "#{t("view.months.#{month_abbr[0]}")}/#{month_abbr[1]}"
  end
end
