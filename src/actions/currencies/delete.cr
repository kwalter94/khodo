class Currencies::Delete < BrowserAction
  delete "/currencies/:currency_id" do
    currency = CurrencyQuery.new.owner_id(current_user.id).find(currency_id)
    DeleteCurrency.delete(currency) do |_operation, _deleted|
      flash.success = "Deleted the currency"
      redirect Index
    end
  end
end
