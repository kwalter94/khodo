import { Controller } from "@hotwired/stimulus";
import * as echarts from "echarts";

export default class extends Controller {
  connect() {
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

    const chart = echarts.init(this.element);
    window.addEventListener("resize", () => chart.resize());
    chart.setOption({
      title: {
        text: "Monthly Transactions by Tag",
      },
      tooltip: {},
      legend: {
        data: ["Income", "Expenses"],
        top: "bottom",
        orient: "horizontal",
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
          data: report.map(({income}) => Math.fround(income)),
          itemStyle: { color: "rgb(0, 255, 128)" },
        },
        {
          name: "Expenses",
          type: "line",
          smooth: true,
          data: report.map(({expenses}) => Math.fround(expenses)),
          itemStyle: { color: "rgb(255, 0, 128)" },
        }
      ],
    });
  }
}
