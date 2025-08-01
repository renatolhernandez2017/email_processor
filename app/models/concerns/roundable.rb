module Roundable
  extend ActiveSupport::Concern

  def round
    decimal = self - to_i

    return to_i.to_f if decimal <= 0.25
    return to_i.to_f + 0.5 if decimal <= 0.75

    to_i.to_f + 1
  end

  def round_to_ten(value)
    rest = value % 10.0
    value - rest + ((rest > 5.0) ? 10 : 0)
  end

  def divide_into_notes(value)
    price = value.to_i
    money_notes = [50, 20, 10]

    money_notes.each_with_object({}) do |money_note, result|
      result[money_note] = price / money_note
      price %= money_note
    end
  end

  class_methods do
    def custom_group_sql
      <<~SQL.squish
        monthly_reports.prescriber_id,
        CASE
          WHEN monthly_reports.accumulated = true THEN 'A'
          WHEN EXISTS (
            SELECT 1 FROM current_accounts
            WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id
              AND current_accounts.standard = TRUE
          ) THEN 'D'
          ELSE 'E'
        END,
        CASE
          WHEN monthly_reports.partnership <= 0 THEN 0
          WHEN EXISTS (
            SELECT 1 FROM current_accounts
            WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id
              AND current_accounts.standard = TRUE
          ) THEN GREATEST(monthly_reports.partnership - monthly_reports.discounts, 0)
          ELSE GREATEST(
            CASE 
              WHEN MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) > 5.0
                THEN (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) + 10
              ELSE (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0)
            END, 0)
        END
      SQL
    end

    def custom_select_sql
      <<~SQL.squish
        monthly_reports.prescriber_id,
        MIN(LPAD(COALESCE(CAST(monthly_reports.envelope_number AS TEXT), '0'), 6, '0')) AS number_envelope,
        SUM(monthly_reports.quantity) AS quantity,
        CASE
          WHEN monthly_reports.accumulated = true THEN 'A'
          WHEN EXISTS (
            SELECT 1 FROM current_accounts
            WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id
              AND current_accounts.standard = TRUE
          ) THEN 'D'
          ELSE 'E'
        END AS situation,
        CASE 
          WHEN monthly_reports.partnership <= 0 THEN 0
          WHEN EXISTS (
            SELECT 1 FROM current_accounts 
            WHERE current_accounts.prescriber_id = monthly_reports.prescriber_id 
              AND current_accounts.standard = TRUE
          ) THEN GREATEST(monthly_reports.partnership - monthly_reports.discounts, 0)
          ELSE GREATEST(
            CASE 
              WHEN MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) > 5.0
                THEN (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) + 10
              ELSE (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0)
            END, 0)
        END AS with_available_value
      SQL
    end
  end
end
