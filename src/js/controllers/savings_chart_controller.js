import { Controller } from "@hotwired/stimulus";
import * as echarts from "echarts";

export default class extends Controller {
  connect() {
    const params = new URLSearchParams(document.location.search);
    const currency_id = params.get("currency_id");

    this
      .fetchSavingsReport(currency_id)
      .then(report => this.renderIncomeVsExpenses(report))
      .then(report => this.renderAverageIncomeVsExpenses(report))
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

  renderIncomeVsExpenses(report) {
    report = report.filter(({period}) => period <= 12);

    const chart = echarts.init(this.element.querySelector("#income-vs-expenses"));
    window.addEventListener("resize", () => chart.resize());
    chart.setOption({
      title: {
        text: "Monthly Income vs Expenses",
      },
      tooltip: {},
      legend: {
        data: ["Income", "Expenses", "Savings"],
        "top": "bottom",
        "orient": "horizontal",
      },
      xAxis: {
        data: report.map(({month}) => month),
      },
      yAxis: {},
      series: [
        {
          name: "Income",
          type: "line",
          smooth: true,
          data: report.map(({income}) => income),
          itemStyle: { color: "rgb(0, 0, 255)" },
        },
        {
          name: "Expenses",
          type: "line",
          smooth: true,
          data: report.map(({expenses}) => expenses),
          itemStyle: { color: "rgb(255, 0, 0)" },
        },
        {
          name: "Savings",
          type: "line",
          smooth: true,
          data: report.map(({savings}) => savings),
          itemStyle: { color: "rgb(0, 128, 0)" },
          areaStyle: { color: "rgba(0, 128, 0, 0.5)" },
        },
      ],
    });

    return report;
  }

  renderAverageIncomeVsExpenses(report) {
    report = report.filter(({period}) => period <= 12);

    const chart = echarts.init(this.element.querySelector("#average-income-vs-expenses"));
    window.addEventListener("resize", () => chart.resize());
    chart.setOption({
      title: {
        text: "Average Monthly Income vs Expenses",
      },
      tooltip: {},
      legend: {
        data: ["Average Income", "Average Expenses", "Average Savings"],
        "top": "bottom",
        "orient": "horizontal",
      },
      xAxis: {
        data: report.map(({month}) => month),
      },
      yAxis: {},
      series: [
        {
          name: "Average Income",
          type: "line",
          smooth: true,
          data: report.map(({average_income}) => average_income),
          itemStyle: { color: "rgb(0, 0, 255)" },
        },
        {
          name: "Average Expenses",
          type: "line",
          smooth: true,
          data: report.map(({average_expenses}) => average_expenses),
          itemStyle: { color: "rgb(255, 0, 0)" },
        },
        {
          name: "Average Savings",
          type: "line",
          smooth: true,
          data: report.map(({average_savings}) => average_savings),
          itemStyle: { color: "rgb(0, 128, 0)" },
          areaStyle: { color: "rgba(0, 128, 0, 0.5)" },
        },
      ],
    });

    return report;

  }
}
