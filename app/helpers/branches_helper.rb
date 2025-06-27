module BranchesHelper
  def calculate_branch_metrics(billings, total_billings)
    @billing = total_billings&.first&.billing || 0

    @total_discounts = 0
    @total_amount_received = total_billings&.sum(&:amount_received) || 0
    @total_number_of_requests = billings&.sum(&:number_of_requests) || 0
    @total_with_partnership = billings&.sum(&:total_requests) || 0
    @cash_partnership = billings&.sum(&:branch_partnership) || 0
    @full_partnership = @cash_partnership + @total_discounts
    @commission_payments_transfers = billings&.sum(&:commission_payments_transfers) || 0

    @representatives = billings&.group_by { |b| b.representative_id } || ["Sem Representante"]
  end
end
