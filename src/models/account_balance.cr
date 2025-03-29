class AccountBalance < BaseModel
  table do
    belongs_to account : Account                  # ameba:disable Lint/UselessAssign
    column balance : Float64 = 0                  # ameba:disable Lint/UselessAssign
    column lifetime_deductions : Float64 = 0      # ameba:disable Lint/UselessAssign
    column lifetime_additions : Float64 = 0       # ameba:disable Lint/UselessAssign
    column current_year_deductions : Float64 = 0  # ameba:disable Lint/UselessAssign
    column current_year_additions : Float64 = 0   # ameba:disable Lint/UselessAssign
    column current_month_deductions : Float64 = 0 # ameba:disable Lint/UselessAssign
    column current_month_additions : Float64 = 0  # ameba:disable Lint/UselessAssign
    belongs_to owner : User                       # ameba:disable Lint/UselessAssign
  end

  def current_month_net_additions : Float64
    current_month_additions - current_month_deductions
  end

  def current_year_net_additions : Float64
    current_year_additions - current_year_deductions
  end

  def lifetime_net_additions : Float64
    lifetime_additions - lifetime_deductions
  end
end
