import { Controller } from "@hotwired/stimulus"

// Lets a list's rows fade and rise into place one after another when the list first appears.
// Rows stay visible without JavaScript: only this controller marks them pending, and CSS does the motion.
// Connects to data-controller="reveal", with each row as data-reveal-target="item"
export default class extends Controller {
  static targets = ["item"]
  static values = {
    stagger: { type: Number, default: 12 },
    logLevel: { type: String, default: "none" }
  }

  connect() {
    if (this.prefersReducedMotion()) return

    this.itemTargets.forEach((item, index) => this.markPending(item, index))
    requestAnimationFrame(() => requestAnimationFrame(() => this.revealAll()))
  }

  prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  // Rows past the stagger limit arrive together, so a long list never makes anyone wait.
  markPending(item, index) {
    item.style.setProperty("--reveal-order", Math.min(index, this.staggerValue))
    item.dataset.reveal = "pending"
  }

  revealAll() {
    this.itemTargets.forEach((item) => { item.dataset.reveal = "shown" })
    this.log(`Revealed ${this.itemTargets.length} rows`)
  }

  log(message) {
    if (this.logLevelValue === "info") console.log(`[Reveal] ${message}`)
  }
}
