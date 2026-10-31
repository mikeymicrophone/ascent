import { Controller } from "@hotwired/stimulus"

// After the pager swaps in another page of a list, gives the list focus so the next page reads from its
// first row. Turbo's autoscroll brings the list's top into view; CSS keeps it clear of the navigation.
// Connects to data-controller="paged-list" on the list's Turbo frame
export default class extends Controller {
  static values = { logLevel: { type: String, default: "none" } }

  settle() {
    this.focusList()
    this.log("Settled on a new page")
  }

  focusList() {
    this.element.setAttribute("tabindex", "-1")
    this.element.focus({ preventScroll: true })
  }

  log(message) {
    if (this.logLevelValue === "info") console.log(`[PagedList] ${message}`)
  }
}
