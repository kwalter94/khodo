import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

export default class extends Controller {
  connect() {
    const params = new URLSearchParams(document.location.search);
    this.currency_id = params.get("currency_id");
    this
      .fetchReport()
      .then(report => this.plotAssetsGrowthChart(report));
  }

  async fetchReport() {
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
    return (await response.json()).filter(({balance, period, account_type_name}) => {
      return period <= 12 && balance != 0 && !["Expense", "Income"].includes(account_type_name);
    });
  }

  plotAssetsGrowthChart(report) {
    console.log(report);
    let months = new Set();
    let accounts = new Map();

    for (const {month, account_name, account_type_name, balance, period} of report) {
      months.add(month);
      const display_name = `${account_name} - ${account_type_name}`;

      if (!accounts.has(display_name)) {
        accounts.set(display_name, Array(12).fill(0));
      }

      const periods = accounts.get(display_name)
      periods[periods.length - period] = balance;
    }

    new Chart(this.element, {
      type: "bar",
      data: {
        labels: [...months.values()].sort(),
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
