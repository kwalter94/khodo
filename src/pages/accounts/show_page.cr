class Accounts::ShowPage < MainLayout
  needs account : Account
  needs balance : AccountBalanceReport
  needs transactions : TransactionQuery

  def content
    div class: "row" { link "Back to all Accounts", Accounts::Index }
    div class: "row" { h1 account.name.to_s }
    div class: "row" { render_actions }
    div class: "row" { render_account_fields }
    div class: "row" { render_transactions }
  end

  def render_actions
    section class: "col-1 offset-md-11" do
      div class: "dropdown" do
        button(
          class: "btn btn-primary dropdown-toggle",
          type: "button",
          id: "actions",
          data_bs_toggle: "dropdown",
          aria_expanded: "false",
        ) { text "Actions" }

        ul class: "dropdown-menu", aria_labelledby: "actions" do
          li { link "Add Expense", Expenses::New.with(account_id: account.id), class: "dropdown-item" }
          li { link "Add Income", Income::New.with(account_id: account.id), class: "dropdown-item" }
          li { link "Add Transfer", Transfers::New.with(account_id: account.id), class: "dropdown-item" }
          li { hr class: "dropdown-divider" }
          li { link "Edit", Accounts::Edit.with(account.id), class: "dropdown-item" }
          li { link "Delete", Accounts::Delete.with(account.id), data_confirm: "Are you sure?", class: "dropdown-item" }
        end
      end
    end
  end

  def render_account_fields
    div class: "col col-6" do
      table class: "table" do
        tbody do
          account_property "Currency:", "#{account.currency.name} (#{account.currency.symbol})"
          account_property "Account type:", account.type.name
        end
      end
    end
    div class: "col col-6" do
      table class: "table" do
        tbody do
          account_property "Current Balance:", format_money(balance.balance, account.currency)
          account_property "Additions (Last 30 Days):", format_money(balance.total_additions_last_month, account.currency)
          account_property "Deductions (Last 30 Days):", format_money(balance.total_deductions_last_month, account.currency)
          account_property "Net Additions (Last 30 Days):", format_money(balance.net_additions_last_month, account.currency)
        end
      end
    end
  end

  def render_transactions
    div class: "col col-12" do
      table class: "table table-dark table-bordered" do
        thead do
          th { text "ID" }
          th { text "Date" }
          th { text "Type" }
          th { text "Description" }
          th { text "Amount (#{account.currency.symbol})" }
          th { text "To/From Account" }
          th { text "Tags" }
        end

        tbody do
          transactions.each do |tx|
            case tx.type(account)
            when "Expense"
              tx_amount = tx.from_amount
              tx_target_account = tx.to_account
              tx_type = "Expense"
            when "Income"
              tx_amount = tx.to_amount
              tx_target_account = tx.from_account
              tx_type = "Income"
            when "Transfer from"
              tx_amount = tx.from_amount
              tx_target_account = tx.to_account
              tx_type = "Transfer from"
            else
              tx_amount = tx.to_amount
              tx_target_account = tx.from_account
              tx_type = "Transfer to"
            end

            tr class: tx_type == "Income" || tx_type == "Transfer to" ? "table-success" : "table-danger" do
              td { link "##{tx.id}", to: Transactions::Show.with(tx.id) }
              td { text tx.transaction_date.to_s("%Y-%m-%d") }
              td { text tx_type }
              td { text tx.description }
              td { text format_money(tx_amount) }
              td { link tx_target_account.name, to: Accounts::Show.with(tx_target_account.id) }
              td do
                tx.tags.each do |tag|
                  span class: "badge bg-success", style: "padding-right: 2px" { text tag.name }
                end
              end
            end
          end
        end
      end
    end
  end

  def account_property(property_name : String, value : String)
    tr do
      th scope: "row" { text property_name }
      td { text value }
    end
  end

  def format_money(amount : Float64, currency : Currency? = nil) : String
    symbol = currency.try(&.symbol) || ""
    return "(#{symbol}#{amount.abs})" if amount.negative?

    "#{symbol}#{amount}"
  end
end
