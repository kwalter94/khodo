class Transactions::IndexPage < MainLayout
  needs transactions : TransactionQuery
  quick_def page_title, "All Transactions"

  def content
    div class: "row" { h1 "All Transactions" }
    div class: "row" { link "New Transaction", to: Transactions::New }
    div class: "row" { render_transactions }
  end

  def render_transactions
    div class: "col col-12" do
      table class: "table table-striped table-dark" do
        thead do
          th { text "ID" }
          th { text "Date" }
          th { text "Description" }
          th { text "From Account" }
          th { text "From Amount" }
          th { text "To Account" }
          th { text "To Amount" }
          th { text "Exchange Rate" }
          th { text "Tags" }
        end

        transactions.each do |tx|
          tr do
            td { link "##{tx.id}", Transactions::Show.with(tx.id) }
            td { text "#{tx.transaction_date.to_s("%Y-%m-%d")}" }
            td { text tx.description[...30] }
            td { link tx.from_account.name, Accounts::Show.with(tx.from_account_id) }
            td { text "#{tx.from_account.currency.symbol}#{tx.from_amount}" }
            td { link tx.to_account.name, Accounts::Show.with(tx.to_account_id) }
            td { text "#{tx.to_account.currency.symbol}#{tx.to_amount}" }
            td { text "#{tx.to_account.currency.symbol}#{tx.to_amount / tx.from_amount} / #{tx.from_account.currency.symbol}" }
            td { text "" }
          end
        end
      end
    end
  end
end
