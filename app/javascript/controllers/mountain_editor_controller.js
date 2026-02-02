import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    maxHeight: Number
  }

  connect() {
    this.draggingRating = false
    this.draggingBaseline = false
    this.activeRatingArea = null
    this.updateApprovalStates()
  }

  startRatingDrag(event) {
    if (!this.isPrimaryPointer(event)) return
    this.draggingRating = true
    this.activeRatingArea = event.currentTarget
    this.capturePointer(event, this.activeRatingArea)
    this.toggleDraggingClass(this.activeRatingArea, true)
    this.updateRatingFromEvent(event)
  }

  dragRating(event) {
    if (!this.draggingRating || !this.activeRatingArea) return
    this.updateRatingFromEvent(event)
  }

  stopRatingDrag(event) {
    if (!this.draggingRating) return
    this.draggingRating = false
    this.toggleDraggingClass(this.activeRatingArea, false)
    this.releasePointer(event, this.activeRatingArea)
    this.activeRatingArea = null
  }

  startBaselineDrag(event) {
    if (!this.isPrimaryPointer(event)) return
    this.draggingBaseline = true
    this.capturePointer(event, event.currentTarget)
    this.toggleBaselineDragging(true)
    this.updateBaselineFromEvent(event)
  }

  dragBaseline(event) {
    if (!this.draggingBaseline) return
    this.updateBaselineFromEvent(event)
  }

  stopBaselineDrag(event) {
    if (!this.draggingBaseline) return
    this.draggingBaseline = false
    this.toggleBaselineDragging(false)
    this.releasePointer(event, event.currentTarget)
  }

  updateRatingFromEvent(event) {
    const ratingArea = this.activeRatingArea || event.currentTarget
    const column = this.closestCandidateColumn(ratingArea)
    if (!column) return

    const ratingValue = this.ratingFromPointer(event, ratingArea)
    this.applyRatingUpdate(column, ratingValue)
  }

  updateBaselineFromEvent(event) {
    const chart = this.chartElement()
    if (!chart) return

    const ratingArea = this.firstRatingArea()
    if (!ratingArea) return

    const ratingValue = this.ratingFromPointer(event, ratingArea)
    this.applyBaselineUpdate(ratingValue)
  }

  applyRatingUpdate(column, ratingValue) {
    const inputId = column.dataset.ratingInputId
    if (!inputId) return

    const input = document.getElementById(inputId)
    if (!input) return

    input.value = ratingValue
    this.updateColumnDisplay(column, ratingValue)
    this.updateApprovalStates()
  }

  applyBaselineUpdate(ratingValue) {
    const input = this.baselineInput()
    if (!input) return

    input.value = ratingValue
    this.updateBaselineIndicator(ratingValue)
    this.updateApprovalStates()
  }

  updateColumnDisplay(column, ratingValue) {
    const ratingDot = column.querySelector("[data-role='rating-dot']")
    if (ratingDot) {
      ratingDot.style.top = `${this.positionFromRating(ratingValue)}px`
      ratingDot.title = `Rating: ${ratingValue} (${this.approvalLabel(ratingValue)})`
    }

    const ratingValueElement = column.querySelector("[data-role='rating-value']")
    const noRatingElement = column.querySelector("[data-role='no-rating']")

    if (ratingValueElement) {
      ratingValueElement.textContent = `Rating: ${ratingValue}`
      ratingValueElement.hidden = false
    }

    if (noRatingElement) {
      noRatingElement.hidden = true
    }
  }

  updateBaselineIndicator(ratingValue) {
    const baselineIndicator = this.baselineIndicator()
    if (!baselineIndicator) return

    baselineIndicator.style.top = `${this.positionFromRating(ratingValue)}px`
    baselineIndicator.title = `Approval Baseline: ${ratingValue}`
    baselineIndicator.dataset.baselineSet = "true"

    const label = baselineIndicator.querySelector("[data-role='baseline-label']")
    if (label) {
      label.textContent = `Baseline: ${ratingValue}`
    }

    const labelContainer = baselineIndicator.querySelector(".baseline-label")
    if (labelContainer) {
      labelContainer.classList.remove("baseline-empty")
    }
  }

  updateApprovalStates() {
    const baselineValue = this.baselineValue()
    const columns = this.candidateColumns()

    columns.forEach((column) => {
      const inputId = column.dataset.ratingInputId
      if (!inputId) return

      const input = document.getElementById(inputId)
      if (!input || input.value === "") {
        this.applyDotState(column, false, false)
        return
      }

      const ratingValue = Number.parseInt(input.value, 10)
      const approved = baselineValue !== null && ratingValue >= baselineValue
      this.applyDotState(column, true, approved)
    })
  }

  applyDotState(column, hasRating, approved) {
    const ratingDot = column.querySelector("[data-role='rating-dot']")
    if (!ratingDot) return

    ratingDot.classList.toggle("unrated", !hasRating)
    ratingDot.classList.toggle("approved", hasRating && approved)
    ratingDot.classList.toggle("disapproved", hasRating && !approved)
  }

  approvalLabel(ratingValue) {
    const baselineValue = this.baselineValue()
    if (baselineValue === null) return "Disapproved"
    return ratingValue >= baselineValue ? "Approved" : "Disapproved"
  }

  baselineValue() {
    const input = this.baselineInput()
    if (!input || input.value === "") return null
    return Number.parseInt(input.value, 10)
  }

  ratingFromPointer(event, areaElement) {
    const rect = areaElement.getBoundingClientRect()
    const relativeY = event.clientY - rect.top
    const height = rect.height || this.maxHeightValue || 320
    const clampedY = Math.max(0, Math.min(relativeY, height))
    const rating = Math.round((1 - clampedY / height) * 500)
    return Math.max(0, Math.min(rating, 500))
  }

  positionFromRating(ratingValue) {
    const height = this.maxHeightValue || 320
    return Math.round(height - (ratingValue / 500.0) * height)
  }

  chartElement() {
    return this.element.querySelector(".mountain-chart")
  }

  baselineIndicator() {
    return this.element.querySelector(".baseline-indicator")
  }

  baselineInput() {
    return this.element.querySelector("[data-mountain-editor-target='baselineInput']")
  }

  candidateColumns() {
    return Array.from(this.element.querySelectorAll(".candidate-column"))
  }

  firstRatingArea() {
    return this.element.querySelector(".rating-area")
  }

  closestCandidateColumn(element) {
    return element.closest(".candidate-column")
  }

  toggleDraggingClass(element, shouldAdd) {
    if (!element) return
    element.classList.toggle("is-dragging", shouldAdd)
  }

  toggleBaselineDragging(shouldAdd) {
    const chart = this.chartElement()
    if (!chart) return
    chart.classList.toggle("baseline-dragging", shouldAdd)
  }

  capturePointer(event, element) {
    if (element?.setPointerCapture && event.pointerId !== undefined) {
      element.setPointerCapture(event.pointerId)
    }
  }

  releasePointer(event, element) {
    if (element?.releasePointerCapture && event.pointerId !== undefined) {
      element.releasePointerCapture(event.pointerId)
    }
  }

  isPrimaryPointer(event) {
    return event.isPrimary !== false
  }
}
