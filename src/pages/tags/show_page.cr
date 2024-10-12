class Tags::ShowPage < MainLayout
  needs tag : Tag
  needs currencies : Enumerable(Currency)
  needs reporting_currency : Currency
  quick_def page_title, "Tag: #{tag.name}"

  def content
    div class: "row" do
      div class: "col col-10" { h1 tag.name }
      div class: "col col-2" { render_actions }
    end

    div class: "row" do
      tag.description.try { |description| para { text description } }

      para class: "text-muted" { text "No description provided" } if tag.description.nil?
    end

    div class: "row" do
      div class: "col col-12" { render_currency_selector }
      div class: "col col-12" do
        empty_tag "canvas",
          data_controller: "monthly-transactions-by-tag-chart"
      end
    end
  end

  private def render_actions
    div class: "dropdown" do
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
end
