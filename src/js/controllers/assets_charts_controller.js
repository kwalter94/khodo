import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

export default class extends Controller {
  connect() {
    const params = new URLSearchParams(document.location.search);
    this.currency_id = params.get("currency_id");
    this.load_report();
  }

  async load_report() {
    let url = "/api/cumulative_assets_report";
    if (this.currency_id) {
      url = `${url}?currency_id=${this.currency_id}`;
    }

    const response = await fetch(url);
    if (response.status != 200) {
      const response_text = await response.text();
      console.error(`Failed to read cumulative_assets_report: ${response_text}`);
      return;
    }

    /** @type Array */
    const report = (await response.json()).filter(({period}) => period <= 12);
    this.plotAssetsGrowthChart(report);
  }

  plotAssetsGrowthChart(report) {
    const ctx = this.element.querySelector("#assets-growth");
    let months = new Set();
    let accounts = new Map();

    for (const {month, account_name, balance} of report) {
      months.add(month);
      if (!accounts.has(account_name)) {
        accounts.set(account_name, []);
      }

      accounts.get(account_name).push(balance);
    }

    new Chart(ctx, {
      type: "bar",
      data: {
        labels: [...months.values()],
        datasets: [...accounts.entries()].map(([label, data]) => ({label, data})),
      },
      options: {
        scales: {
          x: {stacked: true},
          y: {stacked: true},
        },
        plugins: {
          legend: { display: true },
        },
        responsive: true,
      },
    });
  }
}
