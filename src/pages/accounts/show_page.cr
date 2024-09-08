class Accounts::ShowPage < MainLayout
  needs account : Account
  quick_def page_title, "Account with id: #{account.id}"

  def content
    link "Back to all Accounts", Accounts::Index
    h1 "Account with id: #{account.id}"
    render_actions
    render_account_fields
  end

  def render_actions
    section do
      link "Edit", Accounts::Edit.with(account.id)
      text " | "
      link "Delete",
        Accounts::Delete.with(account.id),
        data_confirm: "Are you sure?"
    end
  end

  def render_account_fields
    ul do
      li do
        text "name: "
        strong account.name.to_s
      end
      li do
        text "type: "
        strong account.type.name
      end
      li do
        text "currency: "
        strong account.currency.name
      end
    end
  end
end
