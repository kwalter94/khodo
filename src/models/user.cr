class User < BaseModel
  include Carbon::Emailable
  include Authentic::PasswordAuthenticatable

  table do
    column email : String              # ameba:disable Lint/UselessAssign
    column encrypted_password : String # ameba:disable Lint/UselessAssign
  end

  def emailable : Carbon::Address
    Carbon::Address.new(email)
  end
end
