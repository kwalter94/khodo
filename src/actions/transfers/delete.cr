class Transfers::Delete < BrowserAction
  delete "/transfers/:transaction_id" do
    plain_text "Render something in Transfers::Delete"
  end
end
