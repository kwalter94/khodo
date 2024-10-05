class MonthlySavingsReportSerializer < BaseSerializer
  def initialize(@report : MonthlySavingsReport)
  end

  def render
    {
      month:           @report.month,
      currency_name:   @report.currency_name,
      currency_symbol: @report.currency_symbol,
      income:          @report.income,
      expenses:        @report.expenses,
      savings:         @report.savings,
      period:          @report.period,
    }
  end
end
