class Views::Maps::ShowView < Views::ApplicationView
  prop :explorer, MapExplorer

  def view_template
    div(class: "record-page map-explorer") do
      PageHeader(title: title, eyebrow: "Explore the map", lede: lede,
        trail: (@explorer.state ? [ [ "United States map", map_path ] ] : []), icon_for: ::State) do
        if @explorer.state
          PillLink(label: "United States map", path: map_path, icon: :arrow_left, variant: "outline")
          PillLink(label: "About #{@explorer.state.name}", path: state_path(@explorer.state), variant: "outline")
        end
      end
      map_filters
      map_panel
      place_list
    end
  end

  private

  def title
    @explorer.state ? "Explore #{@explorer.state.name}" : "Explore the United States"
  end

  def lede
    @explorer.state ? "Choose a county or district to see its offices, elections, and races." : "Choose a state, then explore its counties and legislative districts."
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
        div(class: "filter-field") do
          form.label :layer, "Show boundaries", class: "visually-hidden"
          form.select :layer, MapExplorer::LAYERS.map { |value, label| [ label, value ] },
            { selected: @explorer.layer }, class: "filter-select", data: { action: "change->form-submit#submit" }
        end
      end
      button(type: "submit", class: "pill-button") { "Explore" }
    end
  end

  def map_panel
    section(class: "map-panel", aria: { label: "Interactive boundary map" },
      data: { controller: "boundary-map", boundary_map_url_value: features_map_path(state_id: @explorer.state&.id, layer: @explorer.layer),
              boundary_map_selected_state_value: !!@explorer.state,
              action: "turbo:before-cache@document->boundary-map#disconnect" }) do
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
      p(class: "map-vintage", data: { boundary_map_target: "vintage" }) { "Recorded boundary vintages appear when the map loads." }
      p(class: "card-text") { "Source: U.S. Census Bureau TIGER/Line. Display outlines are simplified; recorded boundary dates are shown above." }
      noscript { p(class: "card-text") { "Use the links below to explore without JavaScript." } }
    end
  end

  def place_list
    section(class: "place-section", aria: { label: "#{@explorer.label} links" }) do
      section_heading(@explorer.label, "#{@explorer.records.size} places")
      if @explorer.records.any?
        ul(class: "map-place-links") do
          @explorer.records.each do |record|
            li { link_to record.name, @explorer.record_path(record), class: "text-link" }
          end
        end
      else
        p(class: "card-text") { "No #{@explorer.label.downcase} are recorded here yet. Choose another layer or state." }
      end
    end
  end
end
