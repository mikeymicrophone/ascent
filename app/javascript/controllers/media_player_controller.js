import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "player"]

  play() {
    this.containerTarget.replaceChildren(this.playerTarget.content.cloneNode(true))
    this.containerTarget.querySelector("iframe").focus()
  }
}
