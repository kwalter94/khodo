import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

export default class extends Controller {
  connect() {
    const params = new URLSearchParams(document.location.search);
    const currency_id = params.get("currency_id");

    this
      .fetchSavingsReport(currency_id)
      .then(report => {
        this.renderIncomeVsExpensesChart(report);
        this.renderSavingsChart(report);
      });
  }

  async fetchSavingsReport(currency_id) {
    let url = "api/monthly_savings_report";
    if (currency_id) {
      url = `${url}/?currency_id=${currency_id}`;
    }

    const response = await fetch(url);
    if (response.status !== 200) {
      const response_text = await response.text();
      console.error(`Failed to query monthly savings report: ${response.status} - ${response_text}`);
      throw "Error occured when querying server";
    }

    return await response.json();
  }

  async renderIncomeVsExpensesChart(report) {
    const ctx = this.element.querySelector("#income-vs-expenses");
    report = report.filter(({period}) => period <= 12);

    new Chart(ctx, {
      type: "line",
      data: {
        labels: report.map(({month}) => month),
        datasets: [
          {
            label: "Income",
            data: report.map(({income}) => income),
            borderColor: "rgb(0, 0, 255)",
            backgroundColor: "rgba(0, 0, 255, 0.5)",
          },
          {
            label: "Expenses",
            data: report.map(({expenses}) => expenses),
            borderColor: "rgb(255, 0, 0)",
            backgroundColor: "rgba(255, 0, 0, 0.5)",
          },
        ],
      },
      options: {
        responsive: true,
        legend: { position: "bottom" },
      },
    });
  }

  async renderSavingsChart(report) {
    const ctx = this.element.querySelector("#savings");
    report = report.filter(({period}) => period <= 12);

    new Chart(ctx, {
      type: "line",
      data: {
        labels: report.map(({month}) => month),
        datasets: [
          {
            label: "Savings",
            data: report.map(({savings}) => savings),
            borderColor: "rgb(0, 128, 0)",
            backgroundColor: "rgba(0, 128, 0, 0.5)",
            stepped: true,
            fill: true,
          },
        ],
      },
      options: {
        responsive: true,
        legend: { position: "bottom" },
        interaction: {
          intersect: false,
          axis: "x",
        },
      },
    });
  }
}
