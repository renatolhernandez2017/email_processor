module Prescriber::Aggregations
  extend ActiveSupport::Concern

  class_methods do
    def custom_select_sql
      <<~SQL.squish
        prescribers.*,
        COUNT(prescribers.id) OVER () AS total_count,
        COALESCE(SUM(monthly_reports.quantity), 0) AS quantity,
        COALESCE(SUM(monthly_reports.total_price), 0) AS price,
        COALESCE(SUM(monthly_reports.partnership), 0) AS partnership,
        COALESCE(SUM(monthly_reports.discounts), 0) AS discounts,
        MIN(LPAD(COALESCE(CAST(monthly_reports.envelope_number AS TEXT), '0'), 6, '0')) AS envelope_number,
        SUM(
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
        ) AS available_value,
        COALESCE(SUM(SUM(
          CASE
            WHEN monthly_reports.accumulated = TRUE THEN 1
            WHEN monthly_reports.id IS NULL THEN 1
            ELSE 0
          END
        )) OVER (), 0)::integer AS accumulated_total_count,
        COALESCE(SUM(SUM(
          CASE
            WHEN monthly_reports.accumulated = FALSE THEN 1
            ELSE 0
          END
        )) OVER (), 0)::integer AS real_sale_total_count,
        COALESCE(SUM(SUM(monthly_reports.quantity)) OVER (), 0)::integer AS total_quantity,
        COALESCE(SUM(SUM(
          CASE
            WHEN monthly_reports.accumulated = TRUE THEN
              monthly_reports.quantity
            ELSE 0
          END
        )) OVER (), 0)::integer AS accumulated_total_quantity,
        COALESCE(SUM(SUM(
          CASE
            WHEN monthly_reports.accumulated = FALSE THEN
            monthly_reports.quantity
            ELSE 0
          END
        )) OVER (), 0)::integer AS real_sale_total_quantity,
        SUM(SUM(monthly_reports.total_price)) OVER () AS total_price,
        SUM(SUM(
          CASE
            WHEN monthly_reports.accumulated = TRUE THEN
              monthly_reports.total_price
            ELSE 0
          END
        )) OVER () AS accumulated_total_price,
        SUM(SUM(
          CASE
            WHEN monthly_reports.accumulated = FALSE THEN
              monthly_reports.total_price
            ELSE 0
          END)) OVER () AS real_sale_total_price,
        SUM(SUM(monthly_reports.partnership)) OVER () AS total_partnership,
        SUM(SUM(
          CASE
            WHEN monthly_reports.accumulated = TRUE THEN
              monthly_reports.partnership
            ELSE 0
          END
        )) OVER () AS accumulated_total_partnership,
        SUM(SUM(
          CASE
            WHEN monthly_reports.accumulated = FALSE THEN
              monthly_reports.partnership
            ELSE 0
          END
        )) OVER () AS real_sale_total_partnership,
        SUM(SUM(monthly_reports.discounts)) OVER () AS total_discounts,
        SUM(SUM(
          CASE WHEN monthly_reports.accumulated = TRUE THEN
            monthly_reports.discounts
          ELSE 0
        END
        )) OVER () AS accumulated_total_discounts,
        SUM(SUM(
          CASE WHEN monthly_reports.accumulated = FALSE THEN
            monthly_reports.discounts
          ELSE 0
        END
        )) OVER () AS real_sale_total_discounts,
        SUM(
          CASE
            WHEN SUM(monthly_reports.partnership) <= 0 THEN 0
            WHEN EXISTS (
              SELECT 1 FROM current_accounts
              WHERE current_accounts.prescriber_id = prescribers.id
                AND current_accounts.standard = TRUE
            ) THEN GREATEST(SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts), 0)
            ELSE GREATEST(
              CASE
                WHEN MOD(SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts), 10.0) > 5.0
                  THEN SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts) - MOD(SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts), 10.0) + 10
                ELSE SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts) - MOD(SUM(monthly_reports.partnership) - SUM(monthly_reports.discounts), 10.0)
              END, 0)
          END
        ) OVER ()AS total_available_value,
        SUM(
          CASE
            WHEN SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership ELSE 0 END) <= 0 THEN 0
            WHEN EXISTS (
              SELECT 1 FROM current_accounts
              WHERE current_accounts.prescriber_id = prescribers.id AND current_accounts.standard = TRUE
            ) THEN
              GREATEST(SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 0)
            ELSE GREATEST(
              CASE
                WHEN MOD(SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 10.0) > 5.0 THEN
                  SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END)
                  - MOD(SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 10.0) + 10
                ELSE
                  SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END)
                  - MOD(SUM(CASE WHEN monthly_reports.accumulated = TRUE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 10.0)
              END, 0)
          END
        ) OVER () AS accumulated_total_available_value,
        SUM(
          CASE
            WHEN SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership ELSE 0 END) <= 0 THEN 0
            WHEN EXISTS (
              SELECT 1 FROM current_accounts
              WHERE current_accounts.prescriber_id = prescribers.id AND current_accounts.standard = TRUE) THEN
                GREATEST(SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 0)
            ELSE
              GREATEST(
                CASE
                  WHEN MOD(SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 10) >= 5 THEN
                    SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END)
                      + (10 - MOD(SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 10))
                  ELSE
                    SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END)
                    - MOD(SUM(CASE WHEN monthly_reports.accumulated = FALSE THEN monthly_reports.partnership - monthly_reports.discounts ELSE 0 END), 10)
                END, 0)
          END
        ) OVER () AS real_sale_total_available_value,
        CASE
          WHEN BOOL_OR(monthly_reports.accumulated) THEN 'Acumulado'
          WHEN COUNT(monthly_reports.id) = 0 THEN 'Acumulado'
          WHEN NOT BOOL_OR(monthly_reports.accumulated) AND EXISTS (
            SELECT 1 FROM current_accounts
            WHERE current_accounts.prescriber_id = prescribers.id AND current_accounts.standard = true
          ) THEN (
            SELECT banks.name
            FROM current_accounts
            JOIN banks ON banks.id = current_accounts.bank_id
            WHERE current_accounts.prescriber_id = prescribers.id AND current_accounts.standard = true
            LIMIT 1
          )
          ELSE 'Dinheiro'
        END AS kind
      SQL
    end
  end
end
