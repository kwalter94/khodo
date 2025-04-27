require "db"
require "pg"

module Reports
  class AccountBalance
    DB.mapping(
      {
        account_id:                  Int64,
        account_name:                String,
        currency_id:                 Int64,
        currency_name:               String,
        currency_symbol:             String,
        ledger_id:                   Int64,
        ledger_name:                 String,
        account_type_id:             Int64,
        account_type_name:           String,
        current_month_additions:     PG::Numeric,
        current_month_deductions:    PG::Numeric,
        current_month_net_additions: PG::Numeric,
        current_year_additions:      PG::Numeric,
        current_year_deductions:     PG::Numeric,
        current_year_net_additions:  PG::Numeric,
        lifetime_additions:          PG::Numeric,
        lifetime_deductions:         PG::Numeric,
        balance:                     PG::Numeric,
        owner_id:                    Int64,
      }
    )

    def currency : Currency
      @currency ||= CurrencyQuery.find(currency_id)
    end
  end
end
