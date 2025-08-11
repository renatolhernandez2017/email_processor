module Closing::Aggregations
  extend ActiveSupport::Concern

  class_methods do
    def sum_available_value_sql
      <<~SQL.squish
        SUM(
          CASE
            WHEN monthly_reports.partnership <= 0 THEN 0
            WHEN EXISTS (
              SELECT 1 FROM current_accounts ca2
              WHERE ca2.prescriber_id = monthly_reports.prescriber_id
              AND ca2.standard = TRUE
            ) THEN GREATEST(monthly_reports.partnership - monthly_reports.discounts, 0)
            ELSE GREATEST(
              CASE
                WHEN MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) > 5.0
                  THEN (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) + 10
                ELSE (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0)
              END, 0)
          END
        )
      SQL
    end

    def custom_select_sql
      <<~SQL.squish
        current_accounts.id,
        prescribers.representative_id,
        current_accounts.favored,
        banks.id,
        banks.name AS bank_name,
        banks.agency_number,
        banks.account_number,
        representatives.name AS representative_name,
        #{sum_available_value_sql} AS available_value
      SQL
    end

    def custom_select
      <<~SQL.squish
        COUNT(DISTINCT requests.id) AS quantity,
        COALESCE(SUM(COUNT(DISTINCT requests.id)) OVER (), 0)::integer AS total_quantity,
        SUM(DISTINCT
          CASE
            WHEN monthly_reports.partnership <= 0 THEN 0
            WHEN EXISTS (
              SELECT 1 FROM current_accounts ca2
              WHERE ca2.prescriber_id = monthly_reports.prescriber_id
              AND ca2.standard = TRUE
            ) THEN GREATEST(monthly_reports.partnership - monthly_reports.discounts, 0)
            ELSE GREATEST(
              CASE
                WHEN MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) > 5.0
                  THEN (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) + 10
                ELSE (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0)
              END, 0)
          END
        ) AS available_value,
        SUM(SUM(DISTINCT
          CASE
            WHEN monthly_reports.partnership <= 0 THEN 0
            WHEN EXISTS (
              SELECT 1 FROM current_accounts ca2
              WHERE ca2.prescriber_id = monthly_reports.prescriber_id
              AND ca2.standard = TRUE
            ) THEN GREATEST(monthly_reports.partnership - monthly_reports.discounts, 0)
            ELSE GREATEST(
              CASE
                WHEN MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) > 5.0
                  THEN (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0) + 10
                ELSE (monthly_reports.partnership - monthly_reports.discounts) - MOD((monthly_reports.partnership - monthly_reports.discounts), 10.0)
              END, 0)
          END
        )) OVER () AS total_available_value
      SQL
    end
  end
end
