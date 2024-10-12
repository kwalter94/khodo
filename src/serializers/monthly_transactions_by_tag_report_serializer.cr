class MonthlyTransactionsByTagReportSerializer < BaseSerializer
  def initialize(@report : MonthlyTransactionsByTagReport)
  end

  def render
    {
      month:      @report.month,
      tag:        @report.tag_name,
      income:     @report.total_income,
      expenses:   @report.total_expenses,
      net_income: @report.total_income - @report.total_expenses,
      period:     @report.period,
    }
  end
end
