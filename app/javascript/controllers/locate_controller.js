import { Controller } from "@hotwired/stimulus"

// Asks the browser for the voter's location once, then posts it to the residence preview, which finds
// their places and forgets the point. CSS shows progress and errors through data-locate-state.
// Connects to data-controller="locate"
export default class extends Controller {
  static targets = ["form", "latitude", "longitude", "button", "status"]

  locate() {
    if (!this.isGeolocationAvailable()) return this.showError("This browser can't share a location. Search for your city or town instead.")

    this.showLocating()
    navigator.geolocation.getCurrentPosition(
      (position) => this.submitPosition(position.coords),
      (error) => this.showError(this.errorMessage(error)),
      { enableHighAccuracy: false, timeout: 15000, maximumAge: 600000 }
    )
  }

  isGeolocationAvailable() {
    return "geolocation" in navigator
  }

  submitPosition(coords) {
    this.latitudeTarget.value = coords.latitude.toFixed(6)
    this.longitudeTarget.value = coords.longitude.toFixed(6)
    this.statusTarget.textContent = "Found you. Finding your places…"
    this.formTarget.requestSubmit()
  }

  showLocating() {
    this.element.dataset.locateState = "locating"
    this.buttonTarget.disabled = true
    this.statusTarget.textContent = "Asking your browser for your location…"
  }

  showError(message) {
    this.element.dataset.locateState = "error"
    this.buttonTarget.disabled = false
    this.statusTarget.textContent = message
  }

  errorMessage(error) {
    if (error.code === error.PERMISSION_DENIED) return "Location was declined. Search for your city or town instead."
    if (error.code === error.TIMEOUT) return "Finding your location took too long. Try again, or search instead."
    return "Your location isn't available right now. Search for your city or town instead."
  }
}
