class UserProperties < BaseModel
  table do
    belongs_to currency : Currency? # ameba:disable Lint/UselessAssign
    belongs_to user : User          # ameba:disable Lint/UselessAssign
  end

  class ConfigurationError < Exception
  end
end
