import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"

// Draws each candidate's rating as a peak and moves the range with GSAP: peaks spring up on arrival,
// follow a drag, and a summit pulses lime as it breaks through the baseline. It owns every position
// on the chart (peaks, dots and the baseline line) so they always agree. The mountain editor tells it
// what changed through mountain-editor:rated and mountain-editor:baseline-moved.
// Connects to data-controller="mountain-range"
const PEAK_SPREAD = 70

export default class extends Controller {
  static targets = ["column", "baseline"]
  static values = {
    baseline: { type: Number, default: 250 },
    baselineSet: Boolean,
    logLevel: { type: String, default: "warn" }
  }

  connect() {
    this.line = { value: this.baselineValue }
    this.peaks = new Map(this.columnTargets.map((column) => [ column, this.startingPeak(column) ]))
    this.resizeObserver = new ResizeObserver(() => this.placeBaseline())
    this.resizeObserver.observe(this.element)
    this.drawAll()
    this.markReady()
    this.riseIntoView()
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    gsap.killTweensOf([ this.line, ...this.peaks.values() ])
  }

  rate({ detail: { candidacyId, rating, glide } }) {
    const column = this.columnTargets.find((target) => target.dataset.candidacyId === String(candidacyId))
    if (!column) return

    column.dataset.rating = rating
    this.tween(this.peaks.get(column), { height: rating }, glide, () => this.drawColumn(column))
  }

  moveBaseline({ detail: { baseline, glide } }) {
    this.baselineSetValue = true
    this.tween(this.line, { value: baseline }, glide, () => this.drawAll())
  }

  // A drag follows the pointer closely; a nudge glides and settles.
  tween(target, vars, glide, onUpdate) {
    gsap.to(target, {
      ...vars,
      duration: this.motionAllowed() ? (glide ? 0.45 : 0.12) : 0,
      ease: glide ? "back.out(2)" : "power2.out",
      overwrite: true,
      onUpdate
    })
  }

  riseIntoView() {
    if (!this.motionAllowed()) return

    const peaks = Array.from(this.peaks.values())
    gsap.from(peaks, {
      height: 0,
      duration: 1.1,
      ease: "elastic.out(1, 0.6)",
      stagger: 0.07,
      onUpdate: () => this.drawAll()
    })
  }

  startingPeak(column) {
    return { height: this.ratingOf(column), wasAboveLine: false }
  }

  ratingOf(column) {
    return column.dataset.rating === undefined || column.dataset.rating === "" ? 0 : Number(column.dataset.rating)
  }

  drawAll() {
    this.columnTargets.forEach((column) => this.drawColumn(column))
    this.placeBaseline()
  }

  drawColumn(column) {
    const peak = this.peaks.get(column)
    if (!peak) return

    const height = Math.max(0, Math.min(500, peak.height))
    const baseline = this.line.value
    const aboveLine = this.baselineSetValue && height > baseline
    this.setShape(column, "peak-body", height > 0 ? this.peakPath(height) : "")
    this.setShape(column, "peak-summit", aboveLine ? this.summitPath(height, baseline) : "")
    this.setShape(column, "peak-rope", aboveLine ? this.ropePath(height, baseline) : "")
    this.placeDot(column, height)
    if (aboveLine && !peak.wasAboveLine) this.pulseSummit(column)
    peak.wasAboveLine = aboveLine
  }

  peakPath(height) {
    return `M ${-PEAK_SPREAD} 500 L 0 ${500 - height} L ${PEAK_SPREAD} 500 Z`
  }

  summitPath(height, baseline) {
    const spread = this.spreadAtBaseline(height, baseline)
    return `M ${-spread} ${500 - baseline} L 0 ${500 - height} L ${spread} ${500 - baseline} Z`
  }

  ropePath(height, baseline) {
    const spread = this.spreadAtBaseline(height, baseline)
    return `M ${-spread} ${500 - baseline} H ${spread}`
  }

  spreadAtBaseline(height, baseline) {
    return PEAK_SPREAD * (1 - baseline / height)
  }

  setShape(column, role, path) {
    column.querySelector(`[data-role='${role}']`)?.setAttribute("d", path)
  }

  placeDot(column, height) {
    const dot = column.querySelector("[data-role='rating-dot']")
    if (dot) dot.style.top = `${100 - height / 5}%`
  }

  pulseSummit(column) {
    if (!this.motionAllowed()) return

    const dot = column.querySelector("[data-role='rating-dot']")
    gsap.fromTo(dot, { scale: 1.8 }, { scale: 1, duration: 0.6, ease: "elastic.out(1, 0.4)", overwrite: true })
    this.log(`Summit cleared the baseline in ${column.dataset.candidacyId}`)
  }

  // The line sits in the chart, outside the columns, so it is measured against a rating area.
  placeBaseline() {
    if (!this.hasBaselineTarget) return

    const area = this.columnTargets[0]?.querySelector(".rating-area")
    const parent = this.baselineTarget.offsetParent
    if (!area || !parent) return

    const areaBox = area.getBoundingClientRect()
    const y = areaBox.top - parent.getBoundingClientRect().top + (1 - this.line.value / 500) * areaBox.height
    this.baselineTarget.style.top = `${y - this.baselineTarget.offsetHeight / 2}px`
  }

  markReady() {
    this.element.dataset.rangeReady = "true"
  }

  motionAllowed() {
    return !window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  log(message) {
    if (this.logLevelValue === "debug") console.debug(`[Mountain range] ${message}`)
  }
}
