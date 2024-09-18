class Expenses::Delete < BrowserAction
  delete "/expenses/:expense_id" do
    plain_text "Render something in Expenses::Delete"
  end
end
