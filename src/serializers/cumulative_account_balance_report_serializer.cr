class CumulativeAccountBalanceReportSerializer < BaseSerializer
  def initialize(@report : Reports::CumulativeAccountBalance)
  end

  def render
    {
      month:                 @report.month,
      period:                @report.period,
      account_id:            @report.account_id,
      account_name:          @report.account_name,
      account_type_id:       @report.account_type_id,
      account_type_name:     @report.account_type_name,
      currency_id:           @report.currency_id,
      currency_name:         @report.currency_name,
      receipts:              @report.receipts,
      deductions:            @report.deductions,
      net_receipts:          @report.net_receipts,
      cumulative_receipts:   @report.cumulative_receipts,
      cumulative_deductions: @report.cumulative_deductions,
      balance:               @report.balance,
    }
  end
end
