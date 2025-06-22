import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.log("Dropdown controller connected")
    this.closeDropdown()
    document.addEventListener("click", this.handleOutsideClick.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this))
  }

  toggle() {
    if (this.isOpen()) {
      this.closeDropdown()
    } else {
      this.openDropdown()
    }
  }

  openDropdown() {
    this.element.setAttribute("data-dropdown-open", "true")
    this.log("Dropdown opened")
  }

  closeDropdown() {
    this.element.setAttribute("data-dropdown-open", "false")
    this.log("Dropdown closed")
  }

  isOpen() {
    return this.element.getAttribute("data-dropdown-open") === "true"
  }

  handleOutsideClick(event) {
    if (this.isOpen() && !this.element.contains(event.target)) {
      this.closeDropdown()
      this.log("Dropdown closed by outside click")
    }
  }

  log(message) {
    if (this.logLevel && this.logLevel !== 'none') {
      console.log(`[Dropdown] ${message}`)
    }
  }

  get logLevel() {
    return this.data.get("logLevel") || "info"
  }
}