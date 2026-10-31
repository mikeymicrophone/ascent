import { Controller } from "@hotwired/stimulus"

// Counts a stat tile's number up from zero the first time it scrolls into view. The page renders the real
// number, so it reads correctly without JavaScript or with reduced motion; this only animates the way there.
// Connects to data-controller="count-up" with data-count-up-target-value="4743"
export default class extends Controller {
  static values = {
    target: Number,
    duration: { type: Number, default: 900 },
    logLevel: { type: String, default: "none" }
  }

  connect() {
    if (this.prefersReducedMotion() || this.hasCounted()) return

    this.observer = new IntersectionObserver((entries) => this.startWhenVisible(entries), { threshold: 0.4 })
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }

  prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  hasCounted() {
    return this.element.dataset.counted === "true"
  }

  startWhenVisible(entries) {
    if (!entries.some((entry) => entry.isIntersecting)) return

    this.observer.disconnect()
    this.markCounted()
    this.countFrom(performance.now())
    this.log(`Counting up to ${this.targetValue}`)
  }

  markCounted() {
    this.element.dataset.counted = "true"
  }

  countFrom(start) {
    const step = (now) => {
      const progress = Math.min((now - start) / this.durationValue, 1)
      this.showNumber(Math.round(this.targetValue * this.easeOut(progress)))
      if (progress < 1) requestAnimationFrame(step)
    }
    requestAnimationFrame(step)
  }

  // Quick at first, settling gently on the final number.
  easeOut(progress) {
    return 1 - Math.pow(1 - progress, 3)
  }

  showNumber(number) {
    this.element.textContent = number.toLocaleString("en-US")
  }

  log(message) {
    if (this.logLevelValue === "info") console.log(`[CountUp] ${message}`)
  }
}
