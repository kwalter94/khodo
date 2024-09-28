class Shared::Navbar < BaseComponent
  needs current_user : User

  def render
    nav class: "navbar navbar-expand-lg navbar-light bg-light" do
      div class: "container-fluid" do
        link "Khodo", to: Me::Show, class: "navbar-brand"

        button(
          aria_controls: "navbarSupportedContent",
          aria_expanded: "false",
          aria_label: "Toggle navigation",
          class: "navbar-toggler",
          data_bs_target: "#navbarSupportedContent",
          data_bs_toggle: "collapse",
          type: "button"
        ) do
          span class: "navbar-toggler-icon"
        end

        div class: "collapse navbar-collapse", id: "navbarSupportedContent" do
          ul class: "navbar-nav me-auto mb-2 mb-lg-0" do
            li class: "nav-item" do
              a "Home", aria_current: "page", class: "nav-link active", href: "#"
            end
            li class: "nav-item" do
              link "Accounts", to: Accounts::Index, class: "nav-link"
            end
            li class: "nav-item" do
              link "Transactions", to: Transactions::Index, class: "nav-link"
            end
            li class: "nav-item dropdown" do
              a(
                aria_expanded: "false",
                class: "nav-link dropdown-toggle",
                data_bs_toggle: "dropdown",
                href: "#",
                id: "metadata-dropdown",
                role: "button",
              ) { text "Metadata" }
              ul aria_labelledby: "metadata-dropdown", class: "dropdown-menu" do
                li { link "Currencies", to: Currencies::Index, class: "nav-link" }
                li { link "Exchange Rates", to: ExchangeRates::Index, class: "nav-link" }
                li { link "Tags", to: Tags::Index, class: "nav-link" }
              end
            end
          end

          div class: "nav-item dropdown" do
            a(
              aria_expanded: "false",
              class: "nav-link dropdown-toggle",
              data_bs_toggle: "dropdown",
              href: "#",
              id: "user-dropdown",
              role: "button",
            ) { text current_user.email }
            ul aria_labelledby: "user-dropdown", class: "dropdown-menu" do
              li do
                link "Properties", to: UserProperties::Edit, class: "dropdown-item"
              end
              li do
                a "Security", class: "dropdown-item", href: "#"
              end
              li do
                hr class: "dropdown-divider"
              end
              li do
                link "Sign out", to: SignIns::Delete, class: "dropdown-item", flow_id: "sign-out-button"
              end
            end
          end
        end
      end
    end
  end
end
