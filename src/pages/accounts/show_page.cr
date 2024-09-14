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

  private def render_actions
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

  private def render_account_fields
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

  private def render_transactions
    div class: "col col-12" do
      table class: "table table-bordered" do
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
            row = format_transaction(tx)

            tr class: row.css_class do
              td { link "##{tx.id}", to: Transactions::Show.with(tx.id) }
              td { text row.date }
              td { text row.type }
              td { text row.description }
              td { text row.amount }
              td { link row.counterpart.name, to: Accounts::Show.with(row.counterpart.id) }
              td do
                tx.tags.each do |tag|
                  link tag.name, to: Tags::Show.with(tag.id), class: "badge bg-primary", style: "padding-right: 2px"
                end
              end
            end
          end
        end
      end
    end
  end

  private def account_property(property_name : String, value : String)
    tr do
      th scope: "row" { text property_name }
      td { text value }
    end
  end

  private def format_money(amount : Float64, currency : Currency? = nil) : String
    symbol = currency.try(&.symbol) || ""
    formatted = "#{symbol} #{amount.abs.format(decimal_places: 2)}".strip

    return "(#{formatted})" if amount.negative?

    formatted
  end

  private record TransactionRow,
    date : String,
    type : String,
    description : String,
    amount : String,
    counterpart : Account,
    css_class : String

  private def format_transaction(tx : Transaction) : TransactionRow
    case tx.type(account)
    when "Expense"
      amount = format_money(-tx.from_amount)
      counterpart = tx.to_account
      type = "Expense"
      css_class = "table-danger"
    when "Income"
      amount = format_money(tx.to_amount)
      counterpart = tx.from_account
      type = "Income"
      css_class = "table-success"
    when "Transfer"
      amount = format_money(-tx.from_amount)
      counterpart = tx.to_account
      type = "Transfer"
      css_class = "table-warning"
    else # Receipt
      amount = format_money(tx.to_amount)
      counterpart = tx.from_account
      type = "Receipt"
      css_class = "table-info"
    end

    TransactionRow.new(
      date: tx.transaction_date.to_s("%Y-%m-%d"),
      type: type,
      description: tx.description,
      amount: amount,
      counterpart: counterpart,
      css_class: css_class,
    )
  end
end
