import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  select(event) {
    event.preventDefault()
    this.inputTarget.value = event.params.value
    this.inputTarget.focus()
  }
}
