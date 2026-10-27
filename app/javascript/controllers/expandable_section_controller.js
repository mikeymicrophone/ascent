import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="expandable-section"
export default class extends Controller {
  static targets = ["content", "toggle"]

  connect() {
    this.log("Expandable section controller connected")
  }

  toggle() {
    const isVisible = this.isExpanded()

    if (isVisible) {
      this.collapse()
      this.element.dispatchEvent(new CustomEvent('expandable:closed', { bubbles: true }))
    } else {
      this.expand()
      this.element.dispatchEvent(new CustomEvent('expandable:opened', { bubbles: true }))
    }

    this.log(`Toggled to ${isVisible ? 'collapsed' : 'expanded'}`)
  }

  isExpanded() {
    return this.toggleTarget.getAttribute("aria-expanded") === "true"
  }

  // The chevron turns through CSS on the header's aria-expanded state.
  expand() {
    this.contentTarget.style.display = "block"
    this.toggleTarget.setAttribute("aria-expanded", "true")
    this.element.classList.add("expanded")
  }

  collapse() {
    this.contentTarget.style.display = "none"
    this.toggleTarget.setAttribute("aria-expanded", "false")
    this.element.classList.remove("expanded")
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