class Currencies::Update < BrowserAction
  put "/currencies/:currency_id" do
    currency = CurrencyQuery.find(currency_id)
    SaveCurrency.update(currency, params, owner: current_user) do |operation, updated_currency|
      if operation.saved?
        flash.success = "The record has been updated"
        redirect Show.with(updated_currency.id)
      else
        flash.failure = "It looks like the form is not valid"
        html EditPage, operation: operation, currency: updated_currency
      end
    end
  end
end
