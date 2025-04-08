class NoteDivisionCalculator
  include Roundable

  attr_reader :note_divisions, :total_marks, :total_cash

  def initialize(closing_id)
    @closing_id = closing_id
    @note_divisions = {}
    @total_notes = Hash.new(0)
  end

  def call
    representatives.each do |representative|
      rep_notes = Hash.new(0)

      representative.monthly_reports.each do |report|
        divide_into_notes(report.available_value.to_f).each do |note, count|
          rep_notes[note] += count
          @total_notes[note] += count
        end
      end

      @note_divisions[representative.name] = rep_notes
    end

    @total_marks = @total_notes.values.sum
    @total_cash = @total_notes.sum { |note, count| note * count }

    self
  end

  private

  def representatives
    @representatives ||= Representative.includes(:monthly_reports, :current_accounts)
      .where(monthly_reports: {closing_id: @closing_id, accumulated: false})
      .order(:name)
  end
end
