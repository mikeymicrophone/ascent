import { Controller } from "@hotwired/stimulus"

// Shares a record's link through the device's share sheet, or copies it when there is none.
// Connects to data-controller="share"
export default class extends Controller {
  static targets = ["status"]
  static values = {
    url: String,
    title: String,
    logLevel: { type: String, default: "info" }
  }

  async share() {
    if (this.canUseShareSheet()) {
      await this.openShareSheet()
    } else {
      await this.copyLink()
    }
  }

  canUseShareSheet() {
    return typeof navigator.share === "function"
  }

  async openShareSheet() {
    try {
      await navigator.share({ title: this.titleValue, url: this.urlValue })
      this.log("Shared through the share sheet")
    } catch (error) {
      if (error.name !== "AbortError") await this.copyLink()
    }
  }

  async copyLink() {
    try {
      if (this.canUseClipboard()) {
        await navigator.clipboard.writeText(this.urlValue)
      } else {
        this.copyThroughSelection()
      }
      this.showStatus("Link copied")
      this.log("Copied link to clipboard")
    } catch (error) {
      this.showStatus("Copy failed")
      this.log(`Could not copy link: ${error.message}`)
    }
  }

  // The Clipboard API only exists on secure (https) pages.
  canUseClipboard() {
    return window.isSecureContext && typeof navigator.clipboard?.writeText === "function"
  }

  copyThroughSelection() {
    const field = document.createElement("textarea")
    field.value = this.urlValue
    field.setAttribute("readonly", "")
    field.className = "share-copy-buffer"
    document.body.append(field)
    field.select()
    const copied = document.execCommand("copy")
    field.remove()
    if (!copied) throw new Error("the browser refused to copy")
  }

  showStatus(message) {
    this.statusTarget.textContent = message
    this.element.dataset.shareState = "done"
    clearTimeout(this.statusTimer)
    this.statusTimer = setTimeout(() => this.clearStatus(), 2500)
  }

  clearStatus() {
    this.statusTarget.textContent = ""
    delete this.element.dataset.shareState
  }

  log(message) {
    if (this.logLevelValue !== "none") console.log(`[Share] ${message}`)
  }
}
