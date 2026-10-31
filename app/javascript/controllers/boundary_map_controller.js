import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { cleanPath, track } from "analytics"

const DEFAULT_STYLE = { color: "#6a765c", fillColor: "#dce7c8", fillOpacity: 0.55, weight: 1 }
const SELECTED_STYLE = { color: "#17251e", fillColor: "#bccf55", fillOpacity: 1, weight: 3 }

export default class extends Controller {
  static targets = ["canvas", "status", "vintage", "inset", "insets"]
  static values = { url: String, selectedState: Boolean }

  async connect() {
    this.maps = []
    this.selectedLayer = null
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
      const count = data.features.length
      this.statusTarget.textContent = count
        ? `${count} ${this.selectedStateValue ? "areas" : "states"} mapped. Select a shape to explore.`
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
    this.selectedLayer = null
    this.canvasTarget.hidden = true
    if (this.hasInsetsTarget) this.insetsTarget.hidden = true
  }

  draw(data) {
    const map = this.createMap(this.canvasTarget)
    map.attributionControl.addAttribution("U.S. Census Bureau · TIGER/Line")

    if (this.selectedStateValue) {
      const outline = data.outline && this.unwrapAlaska(data.outline)
      if (outline) {
        this.leaflet.geoJSON(outline, { interactive: false, style: { color: "#17251e", weight: 2, fillOpacity: 0 } }).addTo(map)
      }

      let bounds = outline ? this.leaflet.geoJSON(outline).getBounds() : null
      const groups = (data.layers && data.layers.length) ? data.layers : [{ key: "default", style: DEFAULT_STYLE, features: data.features }]
      groups.forEach(group => {
        const features = (group.features || []).map(feature => this.unwrapAlaska(feature))
        if (!features.length) return
        const style = this.styleFor(group)
        const layerGroup = this.addFeatures(map, features, style)
        if (!bounds || !bounds.isValid()) bounds = layerGroup.getBounds()
        else bounds.extend(layerGroup.getBounds())
      })
      bounds && bounds.isValid() ? map.fitBounds(bounds, { padding: [24, 24] }) : map.setView([38, -97], 4)
    } else {
      const features = data.features.map(feature => this.unwrapAlaska(feature))
      this.addFeatures(map, features.filter(feature => !["AK", "HI"].includes(feature.properties.state_code)), DEFAULT_STYLE)
      map.fitBounds([[24, -125], [50, -66]], { padding: [12, 12] })
      this.insetTargets.forEach(element => {
        const shapes = features.filter(feature => feature.properties.state_code === element.dataset.stateCode)
        if (!shapes.length) {
          element.textContent = "No boundary recorded."
          return
        }
        const inset = this.createMap(element, true)
        const areas = this.addFeatures(inset, shapes, DEFAULT_STYLE)
        const bounds = element.dataset.stateCode === "HI" ? [[18.8, -160.5], [22.3, -154.7]] : areas.getBounds()
        inset.fitBounds(bounds, { padding: [8, 8] })
      })
    }
    this.resizeObserver = new ResizeObserver(() => this.maps.forEach(item => item.invalidateSize()))
    this.resizeObserver.observe(this.canvasTarget)
  }

  styleFor(group) {
    const style = group.style || {}
    return {
      color: style.color || DEFAULT_STYLE.color,
      fillColor: style.fill || style.fillColor || DEFAULT_STYLE.fillColor,
      fillOpacity: 0.45,
      weight: 1.25
    }
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

  addFeatures(map, features, baseStyle) {
    return this.leaflet.geoJSON(features, {
      style: () => ({ ...baseStyle }),
      onEachFeature: (feature, layer) => {
        const label = document.createElement("span")
        const layerLabel = feature.properties.layer_label
        label.textContent = layerLabel ? `${feature.properties.name} (${layerLabel})` : feature.properties.name
        layer.bindTooltip(label, { sticky: true })
        layer.on("mouseover", () => {
          if (this.selectedLayer === layer) return
          layer.setStyle({ ...baseStyle, weight: 2, fillOpacity: 0.75 })
          layer.bringToFront()
        })
        layer.on("mouseout", () => {
          if (this.selectedLayer === layer) return
          layer.setStyle(baseStyle)
        })
        layer.on("click", event => {
          this.selectFeature(layer, baseStyle)
          if (!event.originalEvent?.metaKey && !event.originalEvent?.ctrlKey) {
            this.visitFeature(feature)
          }
        })
        layer.on("add", () => {
          const path = layer.getElement()
          path.setAttribute("tabindex", "0")
          path.setAttribute("role", "link")
          path.setAttribute("aria-label", label.textContent)
          path.addEventListener("keydown", event => {
            if (event.key === "Enter" || event.key === " ") {
              event.preventDefault()
              this.selectFeature(layer, baseStyle)
              this.visitFeature(feature)
            }
          })
          path.addEventListener("focus", () => {
            this.selectFeature(layer, baseStyle)
            layer.openTooltip()
          })
          path.addEventListener("blur", () => {
            if (this.selectedLayer === layer) {
              this.selectedLayer = null
              layer.setStyle(baseStyle)
            }
            layer.closeTooltip()
          })
        })
      }
    }).addTo(map)
  }

  selectFeature(layer, baseStyle) {
    if (this.selectedLayer && this.selectedLayer !== layer) {
      this.selectedLayer.setStyle(this.selectedLayer._ascentBaseStyle || DEFAULT_STYLE)
    }
    layer._ascentBaseStyle = baseStyle
    this.selectedLayer = layer
    layer.setStyle(SELECTED_STYLE)
    layer.bringToFront()
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
