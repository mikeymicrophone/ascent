import { Controller } from "@hotwired/stimulus"
import { cleanPath, track } from "analytics"

// Shares a record's link through the device's share sheet, or copies it when there is none.
// Connects to data-controller="share"
export default class extends Controller {
  static targets = ["status"]
  static values = {
    url: String,
    title: String,
    targetType: String,
    targetId: String,
    logLevel: { type: String, default: "info" }
  }

  async share() {
    this.referralId = Array.from(crypto.getRandomValues(new Uint8Array(16)), byte => byte.toString(16).padStart(2, "0")).join("")
    const url = new URL(this.urlValue)
    url.searchParams.set("ref", this.referralId)
    this.sharedUrl = url.href
    this.trackShare("attempted", this.canUseShareSheet() ? "share_sheet" : "clipboard")
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
      await navigator.share({ title: this.titleValue, url: this.sharedUrl })
      this.trackShare("completed", "share_sheet")
      this.log("Shared through the share sheet")
    } catch (error) {
      this.trackShare(error.name === "AbortError" ? "cancelled" : "failed", "share_sheet")
      if (error.name !== "AbortError") await this.copyLink()
    }
  }

  async copyLink() {
    try {
      if (this.canUseClipboard()) {
        await navigator.clipboard.writeText(this.sharedUrl)
      } else {
        this.copyThroughSelection()
      }
      this.showStatus("Link copied")
      this.trackShare("copied", "clipboard")
      this.log("Copied link to clipboard")
    } catch (error) {
      this.trackShare("failed", "clipboard")
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
    field.value = this.sharedUrl
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

  trackShare(outcome, method) {
    track("share_action", {
      outcome, method, referral_id: this.referralId, target_type: this.targetTypeValue,
      target_id: this.targetIdValue, destination: cleanPath(this.urlValue),
      placement: this.element.closest("section, nav")?.getAttribute("aria-label") || "profile"
    })
  }

  log(message) {
    if (this.logLevelValue !== "none") console.log(`[Share] ${message}`)
  }
}
