module Shared::FormattingHelpers
  def format_money(amount : Float64, currency : Currency? = nil) : String
    symbol = currency.try(&.symbol) || ""
    formatted = "#{symbol} #{amount.abs.format(decimal_places: 2)}".strip

    return "(#{formatted})" if amount.negative?

    formatted
  end

  def format_date(date : Time) : String
    date.to_s("%Y-%m-%d")
  end
end
