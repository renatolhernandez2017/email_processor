module LoadMonthlyReports
  extend ActiveSupport::Concern

  def scoped_monthly_reports(closing_id, eager_load)
    monthly_reports.includes(*eager_load)
      .where(closing_id: closing_id)
      .order("prescribers.name ASC")
  end
end
