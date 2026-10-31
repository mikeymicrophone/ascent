import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { cleanPath, track } from "analytics"

export default class extends Controller {
  static targets = ["canvas", "status", "vintage", "inset", "insets"]
  static values = { url: String, selectedState: Boolean }

  async connect() {
    this.maps = []
    this.request = new AbortController()
    this.statusTarget.textContent = "Loading map. You can also use the place links below."
    const signal = this.request.signal
    try {
      const [leaflet, response] = await Promise.all([
        import("leaflet"), fetch(this.urlValue, { signal, headers: { Accept: "application/json" } })
      ])
      if (!response.ok) throw new Error(`Map request failed: ${response.status}`)
      const data = await response.json()
      if (signal.aborted || !this.element.isConnected) return

      this.leaflet = leaflet
      this.canvasTarget.hidden = false
      if (this.hasInsetsTarget) this.insetsTarget.hidden = false
      this.draw(data)
      this.statusTarget.textContent = data.features.length
        ? `${data.features.length} ${this.selectedStateValue ? "areas" : "states"} mapped. Select a shape to explore.`
        : "No selectable boundaries are recorded for this view. Use the place links below."
      this.vintageTarget.textContent = data.vintages.length
        ? `Boundary ${data.vintages.length === 1 ? "vintage" : "vintages"}: ${data.vintages.join(", ")}`
        : "No boundary vintage recorded."
    } catch (error) {
      if (signal.aborted) return
      this.statusTarget.textContent = "The map could not load. You can still explore using the place links below."
    }
  }

  disconnect() {
    this.request?.abort()
    this.resizeObserver?.disconnect()
    this.maps.forEach(map => map.remove())
    this.maps = []
    this.canvasTarget.hidden = true
    if (this.hasInsetsTarget) this.insetsTarget.hidden = true
  }

  draw(data) {
    const map = this.createMap(this.canvasTarget)
    map.attributionControl.addAttribution("U.S. Census Bureau · TIGER/Line")
    const features = data.features.map(feature => this.unwrapAlaska(feature))

    if (this.selectedStateValue) {
      const outline = data.outline && this.unwrapAlaska(data.outline)
      if (outline) this.leaflet.geoJSON(outline, { interactive: false, style: { color: "#17251e", weight: 2, fillOpacity: 0 } }).addTo(map)
      const areas = this.addFeatures(map, features)
      const bounds = outline ? this.leaflet.geoJSON(outline).getBounds() : areas.getBounds()
      bounds.isValid() ? map.fitBounds(bounds, { padding: [24, 24] }) : map.setView([38, -97], 4)
    } else {
      this.addFeatures(map, features.filter(feature => !["AK", "HI"].includes(feature.properties.state_code)))
      map.fitBounds([[24, -125], [50, -66]], { padding: [12, 12] })
      this.insetTargets.forEach(element => {
        const shapes = features.filter(feature => feature.properties.state_code === element.dataset.stateCode)
        if (!shapes.length) {
          element.textContent = "No boundary recorded."
          return
        }
        const inset = this.createMap(element, true)
        const areas = this.addFeatures(inset, shapes)
        const bounds = element.dataset.stateCode === "HI" ? [[18.8, -160.5], [22.3, -154.7]] : areas.getBounds()
        inset.fitBounds(bounds, { padding: [8, 8] })
      })
    }
    this.resizeObserver = new ResizeObserver(() => this.maps.forEach(item => item.invalidateSize()))
    this.resizeObserver.observe(this.canvasTarget)
  }

  createMap(element, inset = false) {
    const map = this.leaflet.map(element, {
      scrollWheelZoom: false, zoomSnap: 0.25, minZoom: 2, maxZoom: 14,
      zoomControl: !inset, attributionControl: !inset, dragging: !inset,
      touchZoom: !inset, doubleClickZoom: !inset, boxZoom: !inset, keyboard: !inset
    })
    this.maps.push(map)
    return map
  }

  addFeatures(map, features) {
    const style = { color: "#6a765c", weight: 1, fillColor: "#dce7c8", fillOpacity: 0.85 }
    const highlight = { color: "#17251e", weight: 2, fillColor: "#bccf55", fillOpacity: 1 }
    return this.leaflet.geoJSON(features, {
      style,
      onEachFeature: (feature, layer) => {
        const label = document.createElement("span")
        label.textContent = feature.properties.name
        layer.bindTooltip(label, { sticky: true })
        layer.on("mouseover", () => layer.setStyle(highlight))
        layer.on("mouseout", () => layer.setStyle(style))
        layer.on("click", () => this.visitFeature(feature))
        layer.on("add", () => {
          const path = layer.getElement()
          path.setAttribute("tabindex", "0")
          path.setAttribute("role", "link")
          path.setAttribute("aria-label", feature.properties.name)
          path.addEventListener("keydown", event => {
            if (event.key === "Enter" || event.key === " ") {
              event.preventDefault()
              this.visitFeature(feature)
            }
          })
          path.addEventListener("focus", () => { layer.setStyle(highlight); layer.openTooltip() })
          path.addEventListener("blur", () => { layer.setStyle(style); layer.closeTooltip() })
        })
      }
    }).addTo(map)
  }

  unwrapAlaska(feature) {
    if (feature.properties.state_code !== "AK") return feature
    const unwrap = coordinates => typeof coordinates[0] === "number"
      ? [coordinates[0] > 0 ? coordinates[0] - 360 : coordinates[0], coordinates[1]]
      : coordinates.map(unwrap)
    return { ...feature, geometry: { ...feature.geometry, coordinates: unwrap(feature.geometry.coordinates) } }
  }

  visitFeature(feature) {
    track("browse_refined", { method: "map_selection", destination: cleanPath(feature.properties.url), state_code: feature.properties.state_code })
    Turbo.visit(feature.properties.url)
  }
}
