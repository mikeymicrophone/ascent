import { Controller } from "@hotwired/stimulus"

// Keeps the page clear of the fixed navigation as it wraps, loads fonts, or resizes.
// Connects to data-controller="nav-clearance"
export default class extends Controller {
  connect() {
    this.observer = new ResizeObserver(() => this.updateClearance())
    this.observer.observe(this.element)
    this.updateClearance()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  updateClearance() {
    document.documentElement.style.setProperty("--nav-clearance", `${this.navigationHeight()}px`)
  }

  navigationHeight() {
    return this.element.offsetHeight
  }
}
