/* eslint no-console:0 */

// Rails Unobtrusive JavaScript (UJS) is *required* for links in Lucky that use DELETE, POST and PUT.
// Though it says "Rails" it actually works with any framework.
import Rails from "@rails/ujs";
Rails.start();

import bootstrap from "bootstrap";
import { Chart } from "chart.js/auto";  // Autoload chartjs
Chart.defaults.plugins.legend.position = "bottom";

import { Application } from "@hotwired/stimulus";
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers";
window.Stimulus = Application.start();
const context = require.context("./controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))
