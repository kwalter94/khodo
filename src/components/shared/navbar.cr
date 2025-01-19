class Shared::Navbar < BaseComponent
  needs current_user : User # ameba:disable Lint/UselessAssign

  def render
    nav class: "navbar navbar-expand-lg navbar-dark bg-dark" do
      div class: "container-fluid" do
        link "Khodo", to: Home::Index, class: "navbar-brand"

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

        menu
      end
    end
  end

  private def menu
    div class: "collapse navbar-collapse", id: "navbarSupportedContent" do
      ul class: "navbar-nav me-auto mb-2 mb-lg-0" do
        nav_link "Home", to: Home::Index
        nav_link "Accounts", to: Accounts::Index
        nav_link "Tags", to: Tags::Index

        li class: "nav-item dropdown" do
          a(
            aria_expanded: "false",
            class: on_currency_page? ? "nav-link dropdown-togger" : "nav-link dropdown-toggle text-light",
            data_bs_toggle: "dropdown",
            href: "#",
            id: "metadata-dropdown",
            role: "button",
          ) { text "Currencies" }
          ul aria_labelledby: "metadata-dropdown", class: "dropdown-menu" do
            dropdown_link "Manage Currencies", to: Currencies::Index
            dropdown_link "Manage Exchange Rates", to: ExchangeRates::Index
          end
        end
      end

      div class: "nav-item dropdown" do
        a(
          aria_expanded: "false",
          class: "nav-link dropdown-toggle text-light",
          data_bs_toggle: "dropdown",
          href: "#",
          id: "user-dropdown",
          role: "button",
        ) { text current_user.email }
        ul aria_labelledby: "user-dropdown", class: "dropdown-menu" do
          li { small "Version: #{Khodo::VERSION}", class: "dropdown-item-text text-muted" }
          li { hr class: "dropdown-divider" }
          dropdown_link "Properties", to: UserProperties::Edit
          dropdown_link "Security", to: "#"
          li { hr class: "dropdown-divider" }
          dropdown_link "Sign out", to: SignIns::Delete, flow_id: "sign-out-button"
        end
      end
    end
  end

  private def nav_link(label : String, to : BrowserAction.class | String, **extra_attrs)
    if to.is_a?(BrowserAction.class)
      li class: "nav-item" do
        link label, **extra_attrs, to: to, class: current_page?(to) ? "nav-link" : "nav-link active"
      end
    else
      li class: "nav-item" do
        a label, **extra_attrs, href: to, class: "nav-link"
      end
    end
  end

  private def dropdown_link(label : String, to : BrowserAction.class | String, **extra_attrs)
    if to.is_a?(BrowserAction.class)
      li { link label, **extra_attrs, to: to, class: "dropdown-item" }
    else
      li { a label, **extra_attrs, href: to, class: "dropdown-item" }
    end
  end

  private def on_currency_page? : Bool
    current_page?(Currencies::Index) || current_page?(ExchangeRates::Index)
  end
end
