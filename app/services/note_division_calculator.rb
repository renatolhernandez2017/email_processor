class NoteDivisionCalculator
  include Roundable

  attr_reader :note_divisions, :total_marks, :total_cash

  def initialize(closing_id)
    @closing_id = closing_id
    @note_divisions = {}
  end

  def call
    representatives.each do |representative|
      @note_divisions[representative.name] = representative.total_cash(@closing_id)
      @total_marks = @note_divisions[representative.name].values.sum
      @total_cash = @note_divisions[representative.name].sum { |note, count| note * count }
    end

    self
  end

  private

  def representatives
    @representatives ||= Representative.includes(:monthly_reports, :current_accounts)
      .where(monthly_reports: {closing_id: @closing_id, accumulated: false})
      .where.not(monthly_reports: {prescribers: {current_accounts: {id: nil}}})
      .order(:name)
  end
end
