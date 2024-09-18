class Income::Delete < BrowserAction
  delete "/income/:income_id" do
    plain_text "Render something in Income::Delete"
  end
end
