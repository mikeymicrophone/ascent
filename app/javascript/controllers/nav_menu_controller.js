import { Controller } from "@hotwired/stimulus"

// Opens and closes the folded site menu on phones; CSS shows the menu while data-menu-open is true.
// Connects to data-controller="nav-menu"
export default class extends Controller {
  static targets = ["toggle"]

  toggle() {
    this.isOpen() ? this.close() : this.open()
  }

  isOpen() {
    return this.element.dataset.menuOpen === "true"
  }

  open() {
    this.element.dataset.menuOpen = "true"
    this.toggleTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.element.dataset.menuOpen = "false"
    this.toggleTarget.setAttribute("aria-expanded", "false")
  }
}
