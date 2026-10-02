import { Controller } from "@hotwired/stimulus"

// Interactive mountain ratings: drag within a candidate column to set 0–500,
// drag the baseline handle to set the approval threshold.
export default class extends Controller {
  static values = {
    maxHeight: { type: Number, default: 320 }
  }

  connect() {
    this.draggingRating = false
    this.draggingBaseline = false
    this.activeRatingArea = null
    this.boundPointerMove = this.onPointerMove.bind(this)
    this.boundPointerUp = this.onPointerUp.bind(this)
    this.updateApprovalStates()
  }

  disconnect() {
    this.teardownDocumentListeners()
  }

  startRatingDrag(event) {
    if (!this.isPrimaryPointer(event)) return
    if (this.isInteractiveChrome(event.target)) return

    event.preventDefault()
    this.draggingRating = true
    this.draggingBaseline = false
    this.activeRatingArea = event.currentTarget
    this.capturePointer(event, this.activeRatingArea)
    this.toggleDraggingClass(this.activeRatingArea, true)
    this.attachDocumentListeners()
    this.updateRatingFromEvent(event)
  }

  startBaselineDrag(event) {
    if (!this.isPrimaryPointer(event)) return

    event.preventDefault()
    event.stopPropagation()
    this.draggingBaseline = true
    this.draggingRating = false
    this.activeRatingArea = null
    this.capturePointer(event, event.currentTarget)
    this.toggleBaselineDragging(true)
    this.attachDocumentListeners()
    this.updateBaselineFromEvent(event)
  }

  // Kept for data-action bindings; real work is in document listeners while dragging.
  dragRating(event) {
    if (!this.draggingRating) return
    this.updateRatingFromEvent(event)
  }

  dragBaseline(event) {
    if (!this.draggingBaseline) return
    this.updateBaselineFromEvent(event)
  }

  stopRatingDrag() {
    this.finishDrag()
  }

  stopBaselineDrag() {
    this.finishDrag()
  }

  onPointerMove(event) {
    if (this.draggingRating) {
      this.updateRatingFromEvent(event)
    } else if (this.draggingBaseline) {
      this.updateBaselineFromEvent(event)
    }
  }

  onPointerUp() {
    this.finishDrag()
  }

  finishDrag() {
    if (this.draggingRating) {
      this.toggleDraggingClass(this.activeRatingArea, false)
    }
    if (this.draggingBaseline) {
      this.toggleBaselineDragging(false)
    }

    this.draggingRating = false
    this.draggingBaseline = false
    this.activeRatingArea = null
    this.teardownDocumentListeners()
  }

  attachDocumentListeners() {
    document.addEventListener("pointermove", this.boundPointerMove)
    document.addEventListener("pointerup", this.boundPointerUp)
    document.addEventListener("pointercancel", this.boundPointerUp)
  }

  teardownDocumentListeners() {
    document.removeEventListener("pointermove", this.boundPointerMove)
    document.removeEventListener("pointerup", this.boundPointerUp)
    document.removeEventListener("pointercancel", this.boundPointerUp)
  }

  updateRatingFromEvent(event) {
    const ratingArea = this.activeRatingArea
    if (!ratingArea) return

    const column = this.closestCandidateColumn(ratingArea)
    if (!column) return

    const ratingValue = this.ratingFromPointer(event, ratingArea)
    this.applyRatingUpdate(column, ratingValue)
  }

  updateBaselineFromEvent(event) {
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
      const approved = baselineValue !== null && ratingValue > baselineValue
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
    return ratingValue > baselineValue ? "Approved" : "Disapproved"
  }

  baselineValue() {
    const input = this.baselineInput()
    if (!input || input.value === "") return null
    return Number.parseInt(input.value, 10)
  }

  ratingFromPointer(event, areaElement) {
    const rect = areaElement.getBoundingClientRect()
    const clientY = event.clientY ?? event.touches?.[0]?.clientY
    if (clientY === undefined) return 0

    const relativeY = clientY - rect.top
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

  isInteractiveChrome(target) {
    return Boolean(target.closest("a, button, input, textarea, select, label"))
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
      try {
        element.setPointerCapture(event.pointerId)
      } catch (_error) {
        // Ignore if the pointer is already released (common on touch end races).
      }
    }
  }

  isPrimaryPointer(event) {
    return event.isPrimary !== false
  }
}
