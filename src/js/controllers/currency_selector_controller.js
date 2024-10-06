import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["currencyId"];

  connect() {
    console.log("Currency selector connected!");
  }

  onChange() {
    const currencyId = this.currencyIdTarget.value;
    console.log("Currency changed: ", currencyId);
    window.location.assign(`/?currency_id=${currencyId}`);
  }
}
