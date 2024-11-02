class Expenses::NewPage < MainLayout
  needs operation : SaveExpense

  def content
    div class: "row" { h1 "Expense from #{operation.account.name}" }
    div class: "row" { render_form }
  end

  def render_form
    div class: "col-12" do
      form_for Expenses::Create.with(account_id: operation.account.id) do
        mount Expenses::FormFields, operation

        mount Shared::SubmitButton
      end
    end
  end
end
