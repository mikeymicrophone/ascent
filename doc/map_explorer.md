# Map explorer

Open **Jurisdictions → Explore map** or `/map`. Select a state shape to explore its counties. The state view also offers congressional, state senate, and state house / assembly districts. Select a county or district shape to open its existing place page, including the offices, elections, and races recorded there.

Alaska and Hawaii have separate clickable insets on the US overview. Hawaii's inset focuses on the inhabited islands; its state view fits the full recorded boundary. Shapes support keyboard focus and Enter or Space. The state and layer selectors, Explore button, and place links work without JavaScript. Place links also remain available when boundary data is missing or the map request fails.

State and layer selections are shareable URLs:

- `/map` shows US states and DC recorded in the database.
- `/map?state_id=ID` shows that state's counties.
- `/map?state_id=ID&layer=congressional` shows its congressional districts. Other layer values are `counties`, `state_senate`, and `state_house`.
- `/map?state_id=ID&layers[]=counties&layers[]=congressional` overlays multiple layers on one state map. The single `layer` parameter remains supported.
- `/map/features` accepts the same parameters and returns the display GeoJSON, including per-layer groups, a legend payload, and `unavailable_layers` when a selected layer has no geometry. Unknown states, non-US states, and unsupported layers return 404.


## Boundaries and dates

`MapExplorer` reads existing `JurisdictionBoundary` records effective on `Date.current`. The start date is inclusive and the end date is exclusive. Each feature includes the year of its recorded `valid_from` date; the page displays those years as boundary vintages. The existing TIGER import uses January 1 of the supplied vintage as `valid_from`.

The local database inspected for this implementation contains TIGER/Line 2024 boundaries. Displaying those shapes does not verify them for a later election. Update and validate the source boundaries separately when a newer vintage is needed. The existing `gis:import_tiger` task in `lib/tasks/gis.rake` accepts a path or glob and vintage; its task description includes the command and dry-run option.

The endpoint simplifies a copy with PostGIS `ST_SimplifyPreserveTopology`, using 0.03 degrees for the US overview and 0.002 degrees for state views. Stored geometry remains unchanged. Holes and separate polygon parts remain in each feature, but simplification does not guarantee identical borders between neighboring features. The selected state's outline is separate from the selectable county or district layer.

The public GeoJSON contains place names, navigation URLs, state codes, boundary years, and boundary geometry. It does not include voter or residence data. This map does not change residence assignment or eligibility.

## Rendering and development

The `boundary-map` Stimulus controller loads vendored Leaflet 1.9.4 on demand through importmap. No map provider, tile service, API key, gem, or additional environment variable is required. The Leaflet JavaScript license is retained in `vendor/javascript/leaflet.LICENSE`; its CSS and referenced images are local assets. The controller removes maps and cancels pending requests before Turbo caches or disconnects the page.

Run the usual Tailwind build after changing map styles. The request coverage is `spec/requests/maps_spec.rb`; it needs the app's PostGIS test database. Existing boundary imports are prerequisites for seeing shapes in development or production. Missing geometry leaves the place links usable and requires no seed changes for this feature.

## Individual jurisdiction outlines (ASC-114)

Place pages for states, counties, districts, and municipalities show a boundary outline in the side column when an effective `JurisdictionBoundary` exists. Race cards on those pages show a compact outline for the race's office jurisdiction. Missing geometry renders a clear empty state instead of a blank map.

Outlines prefer inline SVG built with PostGIS `ST_AsSVG` on a simplified copy (`ST_SimplifyPreserveTopology`). Holes and separate MultiPolygon parts remain in the path. The panel shows the boundary vintage year and states that displaying that vintage does not verify shapes for a later election. SVG and PNG downloads are available at `/boundary_outlines/:place_type/:place_id.svg` and `.png` (optional `detail=panel|compact`). PNG is rasterized from the same SVG via libvips. Responses include only public outline bytes; voter and residence data are excluded. Stored geometry is never modified.

## Neighbor context (ASC-115)

Place pages show a neighbor panel beside the individual outline. **Same-layer neighbors** are jurisdictions of the same type (and, for districts, the same `kind`) whose effective boundaries `ST_Touches` the selected shape. That includes edge contact and point-touching corners. Interiors that only overlap do not count as same-layer neighbors. An island with no touching peer has an empty same-layer list.

**Overlapping other types** use the existing `Jurisdiction.overlapping` rule (shared area beyond a digitizing sliver) and are listed separately from same-layer neighbors. The neighbor SVG draws peers in a muted style and the selected place highlighted, with links to each place page. County side lists prefer geometric adjacency when boundaries exist, and fall back to other counties in the state when they do not.

## State overlays (ASC-116)

On a state map, checkboxes toggle counties and congressional / state legislative district layers together. Each selected layer uses a distinct stroke and fill. The accessible legend lists selected layers and marks unavailable ones. The GeoJSON response includes `layers`, `legend`, and `unavailable_layers`; feature properties carry `layer` and `layer_label` so overlapping shapes stay distinguishable. Selecting a shape brings it forward with a stronger highlight before navigation. Place-link lists are grouped by selected layer for no-JS use.

## Caching, exports, and refresh (ASC-117)

Production uses Solid Cache (`config.cache_store = :solid_cache_store`, `config/cache.yml`). Development uses the in-process memory store when caching is enabled.

`MapExplorer#feature_collection` caches derived display GeoJSON for 12 hours under `map_explorer/v2/...`. The key includes the state, selected layers, effective date, and `JurisdictionBoundary.maximum(:updated_at)`, so any boundary write invalidates map payloads without mutating stored geometry. `BoundaryOutline` caches SVG path and viewBox parts under `boundary_outline/v1/...` keyed by boundary id, detail, and `updated_at`. `/map/features` and `/boundary_outlines/...` also send `Cache-Control` with a one-hour public max-age.

SVG remains the preferred place-page and race-card display. PNG downloads use `script/render_svg_to_png` in a subprocess so Rails keeps the SVG upload decoder blocked. Measure local payload sizes with `bin/rails gis:map_payload_report STATE=NY` (feature counts and JSON/SVG/PNG byte sizes). Mobile rendering still relies on Leaflet fitBounds and the existing compact outline component; keep multi-layer selections modest on constrained networks.

### Boundary refresh procedure

1. Obtain Census TIGER/Line files for the desired vintage.
2. Dry-run: `DRY_RUN=1 bin/rails 'gis:import_tiger[path-or-glob,YYYY]'`.
3. Import: `bin/rails 'gis:import_tiger[path-or-glob,YYYY]'`.
4. Optional residence check: `bin/rails gis:check_residences`.
5. Confirm map vintages on `/map` and place-page outlines. Displaying a vintage does not verify it for a later election.
6. Cache entries expire by `updated_at` in the key; no manual cache clear is required after import.

### Production coverage audit note

A read-only production audit was attempted via Railway for project `ascent` / environment `production`. Local `railway run` against that service did not establish the app database connection from this workstation (`Database not found: railway`), so production coverage counts were not verified here. Re-run the audit from a linked production shell with:

```ruby
JurisdictionBoundary.effective_on(Date.current).joins(:jurisdiction).group("jurisdictions.jurisdictionable_type").count
```

and compare US states, counties, and districts with and without effective boundaries. Report gaps only; do not write production data from that check.
