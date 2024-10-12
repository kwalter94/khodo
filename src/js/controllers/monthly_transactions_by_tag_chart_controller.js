import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

export default class extends Controller {
  connect() {
    console.log("Loading controller");
    this.tag_id = document.location.pathname.split("/").pop();
    const params = new URLSearchParams(document.location.search);
    this.currency_id = params.get("currency_id");
    this.load_report();
  }

  async load_report() {
    let url = `/api/monthly_transactions_by_tag_report?tag_id=${this.tag_id}`;
    if (this.currency_id) {
      url = `${url}&currency_id=${this.currency_id}`;
    }

    const response = await fetch(url);
    if (response.status != 200) {
      console.error(`Error retrieving monthly transactions report: ${response.status} - ${await response.text()}`);
      throw "Failed to load monthly transactions by tag report";
    }

    const report = await response.json();
    new Chart(this.element, {
      type: "bar",
      data: {
        labels: report.map(({month}) => month),
        datasets: [
          {
            "label": "Income",
            "data": report.map(({income}) => income),
            "backgroundColor": "rgba(0, 255, 128, 0.5)",
          },
          {
            "label": "Expenses",
            "data": report.map(({expenses}) => expenses),
            "backgroundColor": "rgba(255, 0, 128, 0.5)",
          }
        ],
      },
      options: {
        plugins: {
          legend: { display: true },
        },
        responsive: true,
      },
    });
  }
}
