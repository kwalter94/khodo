class Income::NewPage < MainLayout
  needs operation : SaveIncome

  def content
    div class: "row" { h1 "Income to #{operation.account.name}" }
    div class: "row" { render_form }
  end

  def render_form
    div class: "col col-12" do
      form_for Income::Create.with(account_id: operation.account.id) do
        mount Income::FormFields, operation

        mount Shared::SubmitButton
      end
    end
  end
end
