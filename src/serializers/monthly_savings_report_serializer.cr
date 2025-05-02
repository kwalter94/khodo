class MonthlySavingsReportSerializer < BaseSerializer
  def initialize(@report : Reports::MonthlySavings)
  end

  def render
    {
      month:            @report.month,
      currency_name:    @report.currency_name,
      currency_symbol:  @report.currency_symbol,
      income:           @report.income,
      average_income:   @report.average_income,
      expenses:         @report.expenses,
      average_expenses: @report.average_expenses,
      savings:          @report.savings,
      average_savings:  @report.average_savings,
      period:           @report.period,
    }
  end
end
