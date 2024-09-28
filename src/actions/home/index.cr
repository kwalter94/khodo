class Home::Index < BrowserAction
  # include Auth::AllowGuests

  param currency_id : Int64? = nil

  get "/" do
    fallback_currency = CurrencyQuery
      .new
      .owner_id(current_user.id)
      .created_at.asc_order
      .first?

    if !fallback_currency
      flash.info = "You need to create currencies first"
      return redirect to: Currencies::New
    end

    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).find(id) }
    currency ||= UserPropertiesQuery
      .new
      .preload_currency
      .user_id(current_user.id)
      .first?
      .try(&.currency)
    currency ||= fallback_currency

    html Home::ShowPage, currency: currency
  end
end
