class ExchangeRateMatrixQuery < ExchangeRateMatrix::BaseQuery
  class Table
    @table : Hash(Int64, Hash(Int64, Float64))

    def initialize(matrix : Enumerable(ExchangeRateMatrix))
      @table = {} of Int64 => Hash(Int64, Float64)

      matrix.each do |row|
        row.rate.try do |rate|
          @table[row.from_currency_id] ||= {} of Int64 => Float64
          @table[row.from_currency_id][row.to_currency_id] = rate
        end
      end
    end

    def convert(from_currency_id : Int64, to_currency_id : Int64, amount : Float64) : Float64?
      find_rate(from_currency_id, to_currency_id).try { |rate| rate * amount }
    end

    def find_rate(from_currency_id : Int64, to_currency_id : Int64) : Float64?
      @table.dig(from_currency_id, to_currency_id)
    end
  end

  def as_table : Table
    Table.new(self)
  end
end
