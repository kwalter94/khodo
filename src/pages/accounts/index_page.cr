class Accounts::IndexPage < MainLayout
  needs accounts : AccountQuery
  quick_def page_title, "All Accounts"

  def content
    h1 "All Accounts"
    link "New Account", to: Accounts::New
    render_accounts
  end

  def render_accounts
    ul do
      accounts.each do |account|
        li do
          link account.name, Accounts::Show.with(account)
        end
      end
    end
  end
end
