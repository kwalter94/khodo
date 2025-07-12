class Tags::ShowPage < MainLayout
  needs tag : Tag                                       # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency)               # ameba:disable Lint/UselessAssign
  needs reporting_currency : Currency                   # ameba:disable Lint/UselessAssign
  needs exchange_rates : ExchangeRateMatrixQuery::Table # ameba:disable Lint/UselessAssign
  needs transactions : Enumerable(Transaction)          # ameba:disable Lint/UselessAssign
  needs pages : Lucky::Paginator                        # ameba:disable Lint/UselessAssign
  needs search_tx : String                              # ameba:disable Lint/UselessAssign

  quick_def page_title, "Tag: #{tag.name}"

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Tags", Tags::Index.route},
        {truncate_text(tag.name), Tags::Show.with(tag.id)},
      ]
    div class: "row" do
      div class: "col col-12 col-md-10" { h1 tag.name }
      div class: "col col-12 col-md-2" { render_actions }
    end

    div class: "row" do
      tag.description.try { |description| para { text description } }

      para class: "text-muted" { text "No description provided" } if tag.description.nil?
    end

    div class: "row" do
      div class: "col col-12" { render_currency_selector }
      div class: "col col-12" do
        div class: "chart", data_controller: "monthly-transactions-by-tag-chart" do
          h6 "Monthly Transactions by Tag", class: "text-center"
          para "This chart shows the monthly transactions associated with this tag. It includes both income and expenses."
        end
      end
    end

    div class: "row" do
      render_transactions_search_filter

      mount Shared::TransactionsTable,
        currency: reporting_currency,
        transactions: transactions,
        exchange_rates: exchange_rates

      mount Lucky::Paginator::BootstrapNav, pages
    end
  end

  private def render_actions
    div class: "dropdown d-grid" do
      button(
        class: "btn btn-primary dropdown-toggle",
        type: "button",
        id: "actions",
        data_bs_toggle: "dropdown",
        aria_expanded: "false",
      ) { text "Actions" }

      ul class: "dropdown-menu", aria_labelledby: "actions" do
        li { link "Edit Tag", Tags::Edit.with(tag.id), class: "dropdown-item" }
        li { link "Delete Tag", Tags::Delete.with(tag.id), data_confirm: "Are you sure?", class: "dropdown-item" }
      end
    end
  end

  private def render_currency_selector
    div class: "col col-lg-4 offset-lg-8" do
      div class: "input-group mb-2" do
        span class: "input-group-text" { text "Currency" }
        tag(
          "select",
          class: "form-select form-control",
          aria_label: "Select Currency",
          data_controller: "currency-selector",
          data_action: "currency-selector#onChange",
          data_currency_selector_target: "currencyId",
        ) do
          currencies.each do |currency|
            attrs = currency.id == reporting_currency.id ? [:selected] : [] of Symbol
            option(value: currency.id, attrs: attrs) { text "#{currency.name} (#{currency.symbol})" }
          end
        end
      end
    end
  end

  private def render_transactions_search_filter
    form(
      id: "search_tx_form",
      action: Tags::Show.path(tag.id, currency_id: reporting_currency.id),
      class: "form col col-12",
    ) do
      div class: "input-group mb-3" do
        span class: "input-group-text" { text "Search" }
        input(
          id: "search_tx_input",
          type: "text",
          class: "form-control form-control-lg",
          placeholder: "Search description...",
          name: "search_tx",
          value: search_tx || "",
        )
      end
    end
  end
end
