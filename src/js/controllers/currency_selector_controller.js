import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["currencyId"];

  onChange() {
    const currencyId = this.currencyIdTarget.value;
    const url = new URL(window.location.href);
    url.searchParams.set("currency_id", currencyId);

    window.location.assign(url.toString());
  }
}
