import { Controller } from "@hotwired/stimulus"
import { ascentTheme, themeName } from "chart_theme"

let themeRegistered = false

// Draws the ECharts chart whose settings Ruby built, in the Ascent theme. New settings, as when the
// results switch from residents to visitors, animate from the old chart rather than redrawing it.
// ECharts is large, so it loads only once a page has a chart.
// Connects to data-controller="chart"
export default class extends Controller {
  static values = {
    options: Object,
    logLevel: { type: String, default: "warn" }
  }

  async connect() {
    const echarts = await import("echarts")
    if (!this.element.isConnected) return

    this.registerTheme(echarts)
    this.chart = echarts.init(this.element, themeName, { renderer: "svg" })
    this.chart.setOption(this.optionsWithDefaults())
    this.resizeObserver = new ResizeObserver(() => this.chart.resize())
    this.resizeObserver.observe(this.element)
    this.log("Drew chart")
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    this.chart?.dispose()
    this.chart = null
  }

  optionsValueChanged() {
    if (this.chart) this.chart.setOption(this.optionsWithDefaults(), { notMerge: true })
  }

  registerTheme(echarts) {
    if (this.hasRegisteredTheme()) return

    echarts.registerTheme(themeName, ascentTheme(this.element))
    themeRegistered = true
  }

  hasRegisteredTheme() {
    return themeRegistered
  }

  // ARIA turns the series into a spoken description, so the chart is never only pixels.
  optionsWithDefaults() {
    return { aria: { enabled: true }, animationDuration: 900, animationEasing: "cubicOut", ...this.optionsValue }
  }

  log(message) {
    if (this.logLevelValue === "info") console.log(`[Chart] ${message}`)
  }
}
