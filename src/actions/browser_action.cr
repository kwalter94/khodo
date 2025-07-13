abstract class BrowserAction < Lucky::Action
  include Lucky::ProtectFromForgery

  # By default all actions are required to use underscores.
  # Add `include Lucky::SkipRouteStyleCheck` to your actions if you wish to ignore this check for specific routes.
  include Lucky::EnforceUnderscoredRoute

  # This module disables Google FLoC by setting the
  # [Permissions-Policy](https://github.com/WICG/floc) HTTP header to `interest-cohort=()`.
  #
  # This header is a part of Google's Federated Learning of Cohorts (FLoC) which is used
  # to track browsing history instead of using 3rd-party cookies.
  #
  # Remove this include if you want to use the FLoC tracking.
  include Lucky::SecureHeaders::DisableFLoC

  accepted_formats [:html, :json], default: :html

  # This module provides current_user, sign_in, and sign_out methods
  include Authentic::ActionHelpers(User)

  # When testing you can skip normal sign in by using `visit` with the `as` param
  #
  # flow.visit Me::Show, as: UserFactory.create
  include Auth::TestBackdoor

  # By default all actions that inherit 'BrowserAction' require sign in.
  #
  # You can remove the 'include Auth::RequireSignIn' below to allow anyone to
  # access actions that inherit from 'BrowserAction' or you can
  # 'include Auth::AllowGuests' in individual actions to skip sign in.
  include Auth::RequireSignIn

  include Lucky::Paginator::BackendHelpers

  # `expose` means that `current_user` will be passed to pages automatically.
  #
  # In default Lucky apps, the `MainLayout` declares it `needs current_user : User`
  # so that any page that inherits from MainLayout can use the `current_user`
  expose current_user
  expose ledgers
  expose reporting_currency

  before require_reporting_currency

  # This method tells Authentic how to find the current user
  # The 'memoize' macro makes sure only one query is issued to find the user
  private memoize def find_current_user(id : String | User::PrimaryKeyType) : User?
    UserQuery.new.id(id).first?
  end

  private def ledgers : Enumerable(Ledger)
    current_user.try { |user| LedgerQuery.new.owner_id(user.id) } || [] of Ledger
  end

  private memoize def reporting_currency : Currency
    current_user.try do |user|
      currency = cookies.get?("reporting_currency_id").try do |currency_id|
        CurrencyQuery.new.owner_id(user.id).id(currency_id.to_i64).first?
      end

      return currency if currency

      currency = UserPropertiesQuery.new.user_id(user.id).first?.try do |properties|
        properties.currency_id.try do |currency_id|
          CurrencyQuery.new.owner_id(user.id).id(currency_id).first?
        end
      end

      raise "No reporting currency set for #{user.id}" if currency.nil?

      return currency
    end

    # Workaround for when the user is not logged in (current_user is anonymous)
    Currency.new(
      id: 0,
      name: "Anonymous Currency",
      symbol: "anon",
      owner_id: 0,
      created_at: Time.utc(1970, 1, 1),
      updated_at: Time.utc(1970, 1, 1)
    )
  end

  private def require_reporting_currency
    current_user.try do |user|
      is_reporting_currency_set = UserPropertiesQuery
        .new
        .user_id(user.id)
        .currency_id
        .is_not_nil
        .first?

      return continue if is_reporting_currency_set

      flash.set("warning", "You need to set your reporting currency before you can continue.")
      return redirect to: UserProperties::Edit
    end

    Log.warn { "User not logged in, cannot require reporting currency" }
    continue
  end
end
