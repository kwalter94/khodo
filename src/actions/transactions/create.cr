class Transactions::Create < BrowserAction
  post "/transactions" do
    SaveTransaction.create(params, owner: current_user) do |operation, transaction|
      if transaction
        flash.success = "The record has been saved"
        redirect Show.with(transaction.id)
      else
        flash.failure = "It looks like the form is not valid"
        html NewPage, operation: operation
      end
    end
  end
end
