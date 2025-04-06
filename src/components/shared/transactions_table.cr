class Shared::TransactionsTable < BaseComponent
  include Shared::FormattingHelpers

  needs transactions : Enumerable(Transaction)          # ameba:disable Lint/UselessAssign
  needs currency : Currency                             # ameba:disable Lint/UselessAssign
  needs exchange_rates : ExchangeRateMatrixQuery::Table # ameba:disable Lint/UselessAssign

  def render
    div class: "row" do
      div class: "col col-12" do
        div class: "table-responsive" { render_table }
      end
    end
  end

  private def render_table
    table class: "table table-bordered table-striped" do
      thead do
        th { text "Date" }
        th { text "Description" }
        th { text "Amount (#{currency.symbol})" }
        th { text "From Account" }
        th { text "To Account" }
      end

      tbody do
        transactions.each { |tx| render_table_row(tx) }
      end
    end
  end

  def render_table_row(tx : Transaction)
    tr do
      td { text format_date(tx.transaction_date) }
      td { text tx.description }
      td { text format_money(exchange_rates.convert(tx.from_account.currency_id, currency.id, tx.from_amount)) }
      td { link tx.from_account.name, to: Accounts::Show.with(tx.from_account.id) }
      td { link tx.to_account.name, to: Accounts::Show.with(tx.to_account.id) }
    end
  end
end
