module RepresentativesHelper
  def get_monthly_reports(representative, closing_id)
    @monthly_reports = representative.monthly_reports_false(closing_id, [:requests, {representative: :prescriber}])
      .group_by { |report| [report.envelope_number, report.situation] }
      .map do |info, reports|
      {
        info: info,
        reports: reports
      }
    end

    @situation = @monthly_reports.map { |info| info[:info][1] }.last
    @envelope_number = @monthly_reports.map { |info| info[:info][0] }.last.to_s.rjust(5, "0")
  end
end
