class UserProperties < BaseModel
  table do
    belongs_to currency : Currency
    belongs_to user : User
  end
end
