import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="expandable-section"
export default class extends Controller {
  static targets = ["content", "icon", "toggle"]

  connect() {
    this.log("Expandable section controller connected")
  }

  toggle() {
    const content = this.contentTarget
    const icon = this.iconTarget
    const isVisible = content.style.display !== "none"

    if (isVisible) {
      content.style.display = "none"
      icon.textContent = "▶"
      this.element.classList.remove("expanded")
    } else {
      content.style.display = "block"
      icon.textContent = "▼"
      this.element.classList.add("expanded")
    }

    this.log(`Toggled to ${isVisible ? 'collapsed' : 'expanded'}`)
  }

  log(message) {
    if (this.logLevel && this.logLevel !== 'none') {
      console.log(`[ExpandableSection] ${message}`)
    }
  }

  get logLevel() {
    return this.data.get("logLevel") || "info"
  }
}