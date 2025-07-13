import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["currencyId"];

  onChange() {
    const params = new URLSearchParams();
    params.set("currency_id", this.currencyIdTarget.value);
    params.set("redirect_url", window.location.toString());

    window.location.assign(`/reporting_currency/_update?${params.toString()}`);
  }
}
