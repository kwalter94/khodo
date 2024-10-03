class Shared::FlashMessages < BaseComponent
  Log = ::Log.for(self)

  needs flash : Lucky::FlashStore

  def render
    flash.each do |flash_type, flash_message|
      div class: "flash-#{flash_type} alert alert-#{alert_type(flash_type)}", flow_id: "flash" do
        text flash_message
      end
    end
  end

  private def alert_type(flash_type : String) : String
    case flash_type
    when "failure" then "danger"
    when "success" then "sucess"
    when "info"    then "info"
    when "warning" then "warning"
    else
      Log.warn { "Invalid flash_type: #{flash_type}" }
      "primary"
    end
  end
end
