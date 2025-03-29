class CreateAccountBalances::V20250301093249 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(AccountBalance) do
      primary_key id : Int64 # ameba:disable Lint/UselessAssign

      add_belongs_to account : Account, on_delete: :cascade, unique: true # ameba:disable Lint/UselessAssign
      add_belongs_to owner : User, on_delete: :cascade                    # ameba:disable Lint/UselessAssign

      add balance : Float64                  # ameba:disable Lint/UselessAssign
      add lifetime_additions : Float64       # ameba:disable Lint/UselessAssign
      add lifetime_deductions : Float64      # ameba:disable Lint/UselessAssign
      add current_year_additions : Float64   # ameba:disable Lint/UselessAssign
      add current_year_deductions : Float64  # ameba:disable Lint/UselessAssign
      add current_month_additions : Float64  # ameba:disable Lint/UselessAssign
      add current_month_deductions : Float64 # ameba:disable Lint/UselessAssign

      add_timestamps
    end
  end

  def rollback
    drop table_for(AccountBalance)
  end
end
