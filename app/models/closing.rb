class Closing < ApplicationRecord
  audited

  include PgSearch::Model

  has_many :monthly_reports, dependent: :destroy
  has_many :requests, through: :monthly_reports

  validates :start_date, presence: {message: " deve estar preenchido!"}
  validates :closing, presence: {message: " deve estar preenchido!"}, uniqueness: {message: " já está cadastrado!"}

  def self.perform_closing
    `#{Rails.root.join("script", "converter.sh")} &`
  end

  def self.this_month
    today = Date.today - 1
    find_by("end_date >= ? AND start_date <= ?", today, today)
  end

  def self.update_monthly_report
    @monthly_reports = MonthlyReport.includes(:prescriber, :requisition_discounts)
      .where(accumulated: false, closing_id: Closing.find_by(active: true))
      .where.not(representative_id: nil)

    @monthly_reports.each do |monthly_report|
      @requests = monthly_report.requests.eligible(monthly_report)

      patient_listing = ""

      @requests.each do |request|
        patient_listing << if request.patient_name.present?
          request.patient_name.lstrip[0..23].ljust(24)
        else
          "SN.".ljust(24)
        end

        patient_listing << if request.repeat
          "-R "
        else
          "   "
        end

        patient_listing << request.entry_date.strftime("%d/%m/%y") + " "

        if request.entry_date
          if request.amount_received.to_s && request.nrreq_id && request.branch.present?
            patient_listing << request.entry_date.strftime("%d/%m/%y")
            patient_listing << " " + request.total_amount_for_report.to_s.rjust(8) + " " + request.nrreq_id.rjust(8) + " " + request.branch.name
          end
        elsif !request.entry_date && request.total_price.to_s && request.nrreq_id && request.branch.present?
          patient_listing << "  /  /  "
          patient_listing << " " + request.total_price.to_s.rjust(8) + " " + request.nrreq_id.rjust(8) + " " + request.branch.name
        end

        patient_listing << "\n"
      end

      patient_listing << "\n\n"

      monthly_report.requisition_discounts.each do |discount|
        if discount&.visivel
          patient_listing << discount.description.ljust(25)
          patient_listing << discount.price.to_s.rjust(8)
        end
      end

      monthly_report.report = patient_listing
      monthly_report.save!
    end
  end
end
