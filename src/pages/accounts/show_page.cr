class Accounts::ShowPage < MainLayout
  needs account : Account
  needs balance : AccountBalanceReport
  needs transactions : TransactionQuery
  needs pages : Lucky::Paginator

  def content
    div class: "row" { render_actions }
    div class: "row" { render_account_fields }
    div class: "row" { render_transactions }
    div class: "row" { render_transactions_paginator }
  end

  private def render_actions
    h1 account.name, class: "col-11"

    section class: "col-1" do
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
          li { link "Edit Account", Accounts::Edit.with(account.id), class: "dropdown-item" }
          li { link "Delete Account", Accounts::Delete.with(account.id), data_confirm: "Are you sure?", class: "dropdown-item" }
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
      table class: "table table-bordered table-striped" do
        thead do
          th { text "Date" }
          th { text "Type" }
          th { text "Description" }
          th { text "Amount (#{account.currency.symbol})" }
          th { text "Counterpart" }
          th { text "Tags" }
          th { text "Actions" }
        end

        tbody do
          transactions.each do |tx|
            row = format_transaction(tx)

            tr do
              td { text row.date }
              td(class: row.css_class) { text row.type }
              td { text row.description }
              td(class: row.css_class) { text row.amount }
              td do
                text row.counterpart_amount
                text ["Expense", "Transfer from", "Receipt"].includes?(row.type) ? " to " : " from "
                link row.counterpart.name, to: Accounts::Show.with(row.counterpart.id)
              end
              td do
                tx.tags.each do |tag|
                  link tag.name, to: Tags::Show.with(tag.id), class: "badge bg-primary"
                end
              end
              td do
                div class: "btn-group", role: "group", aria_label: "Actions" do
                  if row.type == "Expense"
                    link "Edit", to: Expenses::Edit.with(tx.id, account_id: account.id), class: "btn btn-primary"
                  elsif row.type == "Income"
                    link "Edit", to: Income::Edit.with(tx.id, account_id: account.id), class: "btn btn-primary"
                  elsif row.type == "Transfer to" || row.type == "Transfer from"
                    link "Edit", to: Transfers::Edit.with(tx.id, account_id: account.id), class: "btn btn-primary"
                  end

                  link "Delete", Transactions::Delete.with(tx.id, account_id: account.id), data_confirm: "Are you sure?", class: "btn btn-danger"
                end
              end
            end
          end
        end
      end
    end
  end

  def render_transactions_paginator
    div class: "row" do
      mount Lucky::Paginator::BootstrapNav, pages
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
    counterpart_amount : String,
    css_class : String

  private def format_transaction(tx : Transaction) : TransactionRow
    tx_type = tx.type(account)
    case tx_type
    when "Expense"
      amount = format_money(tx.from_amount)
      counterpart_amount = format_money(tx.to_amount, tx.to_account.currency)
      counterpart = tx.to_account
      css_class = "table-danger"
    when "Income"
      amount = format_money(tx.to_amount)
      counterpart_amount = format_money(tx.from_amount, tx.from_account.currency)
      counterpart = tx.from_account
      css_class = "table-success"
    when "Transfer from"
      amount = format_money(tx.from_amount)
      counterpart_amount = format_money(tx.to_amount, tx.to_account.currency)
      counterpart = tx.to_account
      css_class = "table-warning"
    when "Transfer to"
      amount = format_money(tx.to_amount)
      counterpart_amount = format_money(tx.from_amount, tx.from_account.currency)
      counterpart = tx.from_account
      css_class = "table-warning"
    when "Receipt"
      amount = format_money(tx.to_amount)
      counterpart_amount = format_money(tx.to_amount, tx.to_account.currency)
      counterpart = tx.to_account
      css_class = "table-info"
    else # "Payment"
      amount = format_money(tx.from_amount)
      counterpart_amount = format_money(tx.from_amount, tx.from_account.currency)
      counterpart = tx.from_account
      css_class = "table-danger"
    end

    TransactionRow.new(
      date: tx.transaction_date.to_s("%Y-%m-%d"),
      type: tx_type,
      description: tx.description,
      amount: amount,
      counterpart: counterpart,
      counterpart_amount: counterpart_amount,
      css_class: css_class,
    )
  end
end
