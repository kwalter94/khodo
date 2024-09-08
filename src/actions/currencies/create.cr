class Currencies::Create < BrowserAction
  post "/currencies" do
    SaveCurrency.create(params, owner: current_user) do |operation, currency|
      if currency
        flash.success = "The record has been saved"
        redirect Show.with(currency.id)
      else
        flash.failure = "It looks like the form is not valid"
        html NewPage, operation: operation
      end
    end
  end
end
