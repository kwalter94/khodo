require "db"
require "../../models/reports/*"

module Reports
  abstract class BaseReportQuery(T)
    include Enumerable(T)

    macro filter(declaration)
      def {{ declaration.var.id }}(value : {{ declaration.type }}) : self
        filters = @filters.dup
        filters << {"{{ declaration.var.id }}", value}

        {{ @type.id }}.new(filters)
      end
    end

    @results : Array(T)?

    def initialize
      initialize([] of Tuple(String, DB::Any))
    end

    protected def initialize(filters : Array(Tuple(String, DB::Any)))
      @filters = filters
      @results = nil
    end

    def each(& : T -> Nil)
      query, args = build_query()

      @results ||= ReportingDatabase.query_all(query, args: args, as: T).to_a

      @results.try do |results|
        results.each { |result| yield result }
      end
    end

    protected abstract def base_sql : String

    protected def build_query : Tuple(String, Array(DB::Any))
      clause, args = build_where_clause()

      query = <<-SQL
        WITH report AS (
          #{base_sql}
        )
        SELECT
          report.*
        FROM report
        #{clause}
      SQL

      {query, args}
    end

    private def build_where_clause : Tuple(String, Array(DB::Any))
      where_text, args, _ = @filters.reduce({String::Builder.new("WHERE "), [] of DB::Any, 1}) do |clause, filter|
        where_text_builder, args_builder, i = clause
        column, value = filter

        where_text_builder << " AND " if i > 1
        where_text_builder << "#{column} = $#{i}"
        args_builder << value

        {where_text_builder, args_builder, i + 1}
      end

      {where_text.to_s, args}
    end
  end
end
