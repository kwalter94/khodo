class Shared::BreadCrumb < BaseComponent
  needs path : Array(Tuple(String, Lucky::RouteHelper)) # ameba:disable Lint/UselessAssign

  def render
    nav aria_label: "breadcrumb" do
      ol class: "breadcrumb", style: "margin: 2px" do
        path.each_with_index do |node, i|
          name, route = node

          if path.size == i + 1
            li class: "breadcrumb-item active", aria_current: "page" { text name }
          else
            li class: "breadcrumb-item" { a name, href: route.path }
          end
        end
      end
    end
  end
end
