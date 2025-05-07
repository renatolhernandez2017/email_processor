module LoadMonthlyReports
  extend ActiveSupport::Concern

  def scoped_monthly_reports(closing_id, eager_load)
    monthly_reports.includes(*eager_load)
      .where(closing_id: closing_id)
      .order("prescribers.name ASC")
  end

  def monthly_reports_load(representative, closing_id)
    monthly_reports = representative.load_monthly_reports(closing_id, [{prescriber: {current_accounts: :bank}}])
    accumulated = monthly_reports.where(accumulated: false)

    totals_by_bank = representative.totals_by_bank(closing_id)
    total_count = totals_by_bank.sum { |bank| bank[:count] }
    total_value = totals_by_bank.sum { |bank| bank[:total] }

    totals_by_store = representative.totals_by_store(closing_id)
    total_count_store = totals_by_store.sum { |store| store[:count] }
    total_store = totals_by_store.sum { |store| store[:total] }

    total_in_cash = representative.total_cash(closing_id)
    total_marks = total_in_cash.values.sum
    total_cash = total_in_cash.sum { |key, value| key * value }

    {
      monthly_summary: {
        monthly_reports: monthly_reports,
        accumulated: accumulated
      },
      banks: {
        totals_by_bank: totals_by_bank,
        total_count: total_count,
        total_value: total_value
      },
      stores: {
        totals_by_store: totals_by_store,
        total_count_store: total_count_store,
        total_store: total_store
      },
      cashes: {
        total_in_cash: total_in_cash,
        total_marks: total_marks,
        total_cash: total_cash
      }
    }
  end
end
