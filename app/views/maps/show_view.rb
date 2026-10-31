# frozen_string_literal: true

class Views::Maps::ShowView < Views::ApplicationView
  prop :explorer, MapExplorer

  def view_template
    div(class: "record-page map-explorer", data: { analytics_result_count: @explorer.records.size }) do
      PageHeader(title: title, eyebrow: "Explore the map", lede: lede,
        trail: (@explorer.state ? [ [ "United States map", map_path ] ] : []), icon_for: ::State) do
        if @explorer.state
          PillLink(label: "United States map", path: map_path, icon: :arrow_left, variant: "outline")
          PillLink(label: "About #{@explorer.state.name}", path: state_path(@explorer.state), variant: "outline")
        end
      end
      map_filters
      map_panel
      place_lists
    end
  end

  private

  def title
    @explorer.state ? "Explore #{@explorer.state.name}" : "Explore the United States"
  end

  def lede
    if @explorer.state
      "Toggle counties and district layers together, then choose a shape to open its place page."
    else
      "Choose a state, then explore its counties and legislative districts."
    end
  end

  def map_filters
    form_with(url: map_path, method: :get, class: "filter-form map-filters", local: true,
      data: { controller: "form-submit" }, html: { aria: { label: "Choose map area" } }) do |form|
      div(class: "filter-field") do
        form.label :state_id, "State", class: "visually-hidden"
        form.select :state_id, @explorer.states.map { [ it.name, it.id ] },
          { include_blank: "United States", selected: @explorer.state&.id },
          class: "filter-select", data: { action: "change->form-submit#submit" }
      end
      if @explorer.state
        fieldset(class: "map-layer-toggles") do
          legend(class: "map-layer-legend-title") { "Boundary layers" }
          MapExplorer::LAYERS.each do |value, label|
            label(class: "map-layer-toggle") do
              input(
                type: "checkbox",
                name: "layers[]",
                value: value,
                checked: @explorer.layers.include?(value),
                data: { action: "change->form-submit#submit" }
              )
              span { label }
            end
          end
        end
      end
      button(type: "submit", class: "pill-button") { "Explore" }
    end
  end

  def map_panel
    section(class: "map-panel", aria: { label: "Interactive boundary map" },
      data: {
        controller: "boundary-map",
        boundary_map_url_value: features_map_path(state_id: @explorer.state&.id, layers: @explorer.layers),
        boundary_map_selected_state_value: !!@explorer.state,
        action: "turbo:before-cache@document->boundary-map#disconnect"
      }) do
      p(class: "map-status", role: "status", data: { boundary_map_target: "status" }) { "Explore using the map or the place links below." }
      div(class: "map-canvas", role: "region", hidden: true, aria: { label: "#{title} interactive map" }, data: { boundary_map_target: "canvas" })
      unless @explorer.state
        div(class: "map-insets", hidden: true, data: { boundary_map_target: "insets" }) do
          %w[AK HI].each do |code|
            div(class: "map-inset") do
              h2(class: "map-inset-title") { code == "AK" ? "Alaska" : "Hawaii" }
              div(class: "map-inset-canvas", role: "region", aria: { label: "#{code == "AK" ? "Alaska" : "Hawaii"} map" },
                data: { boundary_map_target: "inset", state_code: code })
            end
          end
        end
      end
      render_legend if @explorer.state
      render_unavailable if @explorer.state
      p(class: "map-vintage", data: { boundary_map_target: "vintage" }) { "Recorded boundary vintages appear when the map loads." }
      p(class: "card-text") { "Source: U.S. Census Bureau TIGER/Line. Display outlines are simplified; recorded boundary dates are shown above." }
      noscript { p(class: "card-text") { "Use the links below to explore without JavaScript." } }
    end
  end

  def render_legend
    ul(class: "map-legend", aria: { label: "Map layer legend" }) do
      @explorer.layer_status.select { it[:selected] }.each do |entry|
        li(class: [ "map-legend-item", ("is-unavailable" unless entry[:available]) ].compact.join(" ")) do
          span(class: "map-legend-swatch", style: { background: entry[:style][:fill], border_color: entry[:style][:color] })
          span { entry[:label] }
          span(class: "map-legend-count") { entry[:available] ? "#{entry[:feature_count]} mapped" : "unavailable" }
        end
      end
    end
  end

  def render_unavailable
    missing = @explorer.unavailable_layers
    return if missing.empty?

    p(class: "map-unavailable", role: "status") do
      "Unavailable on this map: #{missing.map { it[:label] }.to_sentence}. No boundary geometry is recorded for #{'that layer'.pluralize(missing.size)} yet."
    end
  end

  def place_lists
    if @explorer.state
      @explorer.layers.each do |layer_key|
        places = @explorer.records_for(layer_key)
        section(class: "place-section", aria: { label: "#{MapExplorer::LAYERS.fetch(layer_key)} links" }) do
          section_heading(MapExplorer::LAYERS.fetch(layer_key), "#{places.size} places")
          if places.any?
            ul(class: "map-place-links") do
              places.each { |record| li { link_to record.name, @explorer.record_path(record), class: "text-link" } }
            end
          else
            p(class: "card-text") { "No #{MapExplorer::LAYERS.fetch(layer_key).downcase} are recorded here yet." }
          end
        end
      end
    else
      section(class: "place-section", aria: { label: "States links" }) do
        section_heading("States", "#{@explorer.records.size} places")
        ul(class: "map-place-links") do
          @explorer.records.each { |record| li { link_to record.name, @explorer.record_path(record), class: "text-link" } }
        end
      end
    end
  end
end
