module RepresentativesHelper
  include Roundable

  def set_calculate_totals(monthly_reports)
    total_by_bank(monthly_reports)
    total_by_store(monthly_reports)
    total_cash(monthly_reports)
  end

  private

  def total_by_bank(monthly_reports)
    @totals_by_bank = monthly_reports
      .group_by { |m| m.prescriber&.current_accounts&.find_by(standard: true)&.bank&.name }
      .reject { |bank, _| bank.nil? }
      .map do |bank, reports|
        {
          count: reports.size,
          name: bank,
          total: reports.sum { |r| r.partnership - r.discounts }
        }
      end

    @totals_count = @totals_by_bank.sum { |bank| bank[:count] }
    @total_bank = @totals_by_bank.sum { |bank| bank[:total] }
  end

  def total_by_store(monthly_reports)
    @totals_by_store = monthly_reports
      .group_by { |m| m.prescriber&.representative&.branch&.name }
      .map do |branch, reports|
      {
        name: branch,
        count: reports.sum { |r| r.requests.count },
        total: reports.sum { |r| r.requests.sum(&:amount_received) }
      }
    end

    @total_count_store = @totals_by_store.sum { |store| store[:count] }
    @total_store = @totals_by_store.sum { |store| store[:total] }
  end

  def total_cash(monthly_reports)
    @total_in_cash = monthly_reports
      .joins(prescriber: :current_accounts)
      .where.not(prescriber: {current_accounts: {id: nil}})
      .map { |mr| divide_into_notes(mr.available_value.to_f) }
      .each_with_object(Hash.new(0)) { |hash, sums|
      hash.each { |key, value| sums[key] += value }
    }

    @total_marks = @total_in_cash.values.sum
    @total_cash = @total_in_cash.map { |key, value| key * value }.sum
  end
end
