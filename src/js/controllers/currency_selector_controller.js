import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["currencyId"];

  onChange() {
    const currencyId = this.currencyIdTarget.value;
    const currentLocation = window.location.toString().split("?")[0];

    window.location.assign(`${currentLocation}?currency_id=${currencyId}`);
  }
}
