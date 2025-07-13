class ReportingCurrency::Index < BrowserAction
  param currency_id : Int64   # ameba:disable Lint/UselessAssign
  param redirect_url : String # ameba:disable Lint/UselessAssign

  get "/reporting_currency/_update" do
    currency = CurrencyQuery.new.owner_id(current_user.id).find(currency_id)
    cookies.set("reporting_currency_id", currency.id.to_s)

    redirect to: redirect_url
  end
end
