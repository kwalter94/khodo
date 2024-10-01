import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

export default class extends Controller {
  connect() {
    new Chart(this.element, {
      type: "bar",
      data: {
        labels: ["Red", "Green", "Blue"],
        datasets: [
          {
            label: "Colours",
            data: [10, 2, 7],
            borderWidth: 1,
          }
        ],
        options: {
          scales: {
            y: { beginAtZero: true },
          },
        },
      },
    });
  }
}
