class DeleteTransaction < Transaction::DeleteOperation
  # Read more on deleting records
  # https://luckyframework.org/guides/database/deleting-records

  after_delete do |tx|
    SaveAccountBalance.reverse_transaction(tx)
  end
end
