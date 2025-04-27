class Accounts::ShowPage < MainLayout
  needs account_balance : Reports::AccountBalance # ameba:disable Lint/UselessAssign
  needs transactions : TransactionQuery           # ameba:disable Lint/UselessAssign
  needs pages : Lucky::Paginator                  # ameba:disable Lint/UselessAssign
  needs search_description : String?              # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {
          "#{account_balance.ledger_name} Accounts",
          Accounts::Index.route(ledger_id: account_balance.ledger_id),
        },
        {
          truncate_text(account_balance.account_name, length: 20),
          Accounts::Show.with(account_balance.account_id),
        },
      ]

    div class: "row" { render_actions }
    div class: "row" { render_account_fields }
    div class: "row" { render_search_filters }
    div class: "row" { render_transactions }
    div class: "row" { render_transactions_paginator }
  end

  private def render_actions
    div class: "col col-12 col-md-8" { h1 account_balance.account_name }

    div class: "col col-12 offset-md-2 col-md-2" do
      section do
        div class: "dropdown d-grid gap-2" do
          button(
            class: "btn btn-primary dropdown-toggle",
            type: "button",
            id: "actions",
            data_bs_toggle: "dropdown",
            aria_expanded: "false",
          ) { text "Actions" }

          ul class: "dropdown-menu", aria_labelledby: "actions" do
            li { link "Add Expense", Expenses::New.with(account_id: account_balance.account_id), class: "dropdown-item" }
            li { link "Add Income", Income::New.with(account_id: account_balance.account_id), class: "dropdown-item" }
            li { link "Add Transfer", Transfers::New.with(account_id: account_balance.account_id), class: "dropdown-item" }
            li { hr class: "dropdown-divider" }
            li { link "Edit Account", Accounts::Edit.with(account_balance.account_id), class: "dropdown-item" }
            li { link "Delete Account", Accounts::Delete.with(account_balance.account_id), data_confirm: "Are you sure?", class: "dropdown-item" }
          end
        end
      end
    end
  end

  private def render_account_fields
    div class: "col col-xl-4 col-md-12" do
      table class: "table" do
        tbody do
          account_property "Currency:", "#{account_balance.currency_name} (#{account_balance.currency_symbol})"
          account_property "Account type:", account_balance.account_type_name
          account_property "Ledger:", account_balance.ledger_name || "N/A"
        end
      end
    end
    div class: "col col-xl-8 col-md-12" do
      table class: "table" do
        tbody do
          account_property "Current Balance:", format_money(account_balance.balance, account_balance.currency)
          account_property(
            "Additions (month | year | lifetime):",
            format_money(account_balance.current_month_additions, account_balance.currency),
            format_money(account_balance.current_year_additions, account_balance.currency),
            format_money(account_balance.lifetime_additions, account_balance.currency),
          )
          account_property(
            "Deductions (month | year | lifetime):",
            format_money(account_balance.current_month_deductions, account_balance.currency),
            format_money(account_balance.current_year_deductions, account_balance.currency),
            format_money(account_balance.lifetime_deductions, account_balance.currency),
          )
          account_property(
            "Net Additions (month | year | lifetime):",
            format_money(account_balance.current_month_net_additions, account_balance.currency),
            format_money(account_balance.current_year_net_additions, account_balance.currency),
            format_money(account_balance.balance, account_balance.currency),
          )
        end
      end
    end
  end

  private def render_search_filters
    form id: "search_description", action: Accounts::Show.path(account_balance.account_id), class: "form col col-12" do
      div class: "input-group mb-3" do
        span class: "input-group-text" { text "Search" }
        input(
          id: "search_description",
          type: "text",
          class: "form-control form-control-lg",
          placeholder: "Description...",
          name: "search_description",
          value: search_description || "",
        )
      end
    end
  end

  private def render_transactions
    div class: "col col-12" do
      div class: "table-responsive" do
        table class: "table table-bordered table-striped" do
          thead do
            th { text "Date" }
            th { text "Type" }
            th { text "Description" }
            th { text "Amount" }
            th { text "D/E Amount" }
            th { text "D/E Account" }
            th { text "Tags" }
            th { text "Actions" }
          end

          tbody do
            transactions.each do |tx|
              row = format_transaction(tx)

              tr do
                td { text tx.transaction_date.to_s("%Y-%m-%d") }
                td(class: row.css_class) { text tx.type }
                td { text tx.description }
                td(class: row.css_class) { text row.amount }
                td(class: row.css_class) { double_entry_amount(tx) }
                td { double_entry_account(tx) }
                td do
                  tx.tags.each do |tag|
                    link tag.name, to: Tags::Show.with(tag.id), class: "badge bg-primary"
                  end
                end
                td do
                  div class: "btn-group", role: "group", aria_label: "Actions" do
                    if tx.type == "Expense" && account_balance.account_type_name != "Expense"
                      link "Edit", to: Expenses::Edit.with(tx.id, account_id: account_balance.account_id), class: "btn btn-primary"
                    elsif tx.type == "Income" && account_balance.account_type_name != "Income"
                      link "Edit", to: Income::Edit.with(tx.id, account_id: account_balance.account_id), class: "btn btn-primary"
                    elsif tx.type == "Swap"
                      link "Edit", to: Transfers::Edit.with(tx.id, account_id: account_balance.account_id), class: "btn btn-primary"
                    end

                    link "Delete", Transactions::Delete.with(tx.id, account_id: account_balance.account_id), data_confirm: "Are you sure?", class: "btn btn-danger"
                  end
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

  private def account_property(property_name : String, *values : String)
    tr do
      th scope: "row" { text property_name }
      values.each do |value|
        td style: "text-align: right" { text value }
      end
    end
  end

  private def format_money(amount : Float64 | PG::Numeric, currency : Currency? = nil) : String
    amount = amount.to_f64
    symbol = currency.try(&.symbol) || ""
    formatted = "#{symbol} #{amount.abs.format(decimal_places: 2)}".strip

    return "(#{formatted})" if amount.negative?

    formatted
  end

  private record TransactionRow,
    amount : String,
    css_class : String

  private def format_transaction(tx : Transaction) : TransactionRow
    tx_type = tx.type
    case tx_type
    when "Expense"
      amount = format_money(tx.from_amount, tx.from_account.currency)
      css_class = "table-danger"
    when "Income"
      amount = format_money(tx.to_amount, tx.to_account.currency)
      css_class = "table-success"
    else # "Swap"
      amount = if tx.from_account.id == account_balance.account_id
                 format_money(tx.from_amount, tx.from_account.currency)
               else
                 format_money(tx.to_amount, tx.to_account.currency)
               end

      css_class = "table-warning"
    end

    TransactionRow.new(
      amount: amount,
      css_class: css_class,
    )
  end

  private def double_entry_account(tx : Transaction)
    case tx.type
    when "Income"
      if account_balance.account_id == tx.to_account.id && account_balance.account_type_name != "Income"
        text "from: "
        link tx.from_account.name, to: Accounts::Show.with(tx.from_account.id)
      else
        text "to: "
        link tx.to_account.name, to: Accounts::Show.with(tx.to_account.id)
      end
    when "Expense"
      if account_balance.account_id == tx.from_account.id && account_balance.account_type_name != "Expense"
        text "to: "
        link tx.to_account.name, to: Accounts::Show.with(tx.to_account.id)
      else
        text "from: "
        link tx.from_account.name, to: Accounts::Show.with(tx.from_account.id)
      end
    else # Swap
      if account_balance.account_id == tx.from_account.id
        text "to: "
        link tx.to_account.name, to: Accounts::Show.with(tx.to_account.id)
      else
        text "from: "
        link tx.from_account.name, to: Accounts::Show.with(tx.from_account.id)
      end
    end
  end

  private def double_entry_amount(tx : Transaction)
    if account_balance.account_id == tx.from_account.id
      text format_money(tx.to_amount, tx.to_account.currency)
    elsif account_balance.account_id == tx.to_account.id
      text format_money(tx.from_amount, tx.from_account.currency)
    else
      text " - "
    end
  end
end
