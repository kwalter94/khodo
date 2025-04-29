class MonthlyTransactionsByTagReportSerializer < BaseSerializer
  def initialize(@report : Reports::MonthlyTransactionsByTag)
  end

  def render
    {
      month:      @report.month,
      tag:        @report.tag_name,
      income:     @report.total_income,
      expenses:   @report.total_expenses,
      net_income: @report.net_income,
      period:     @report.period,
    }
  end
end
