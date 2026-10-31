# frozen_string_literal: true

# A county's page: its own races, then counts of the races its towns decide, the seats it elects, its
# elections, and every town within it as a way down to their own pages.
class Views::Counties::ShowView < Views::ApplicationView
  include Views::PlaceSections

  TOWN_LIMIT = 30
  NEIGHBOR_LIMIT = 8

  prop :county, County

  def view_template
    div(class: "place-page", id: dom_id(@county, :show)) do
      place_header
      fact_tiles
      div(class: "place-layout") do
        div(class: "place-main") do
          ballot_section
          place_chips("Cities and towns", towns.first(TOWN_LIMIT), total: towns.size, see_all: municipalities_path(county_id: @county.id))
          seats_section
          elections_section
        end
        aside(class: "place-aside", aria: { label: "Around #{@county.name}" }) do
          where_it_is
          boundary_side_card
          nearby
          admin_actions
        end

      end
    end
  end

  private

  def place
    @county
  end

  def trail
    trail_for(@county)
  end

  def eyebrow
    "County · #{@county.state.name}"
  end

  def lede
    [
      "#{@county.name} is in #{@county.state.name}, with #{pluralize(towns.size, "city and town", plural: "cities and towns")} on Ascent.",
      seats_sentence,
      open_races_sentence
    ].compact.join(" ")
  end

  def towns
    @towns ||= @county.municipalities.order(:name).to_a
  end

  def fact_tiles
    div(class: "stat-tiles place-facts") do
      StatTile(value: open_races.size.to_s, label: "open #{"race".pluralize(open_races.size)} decided by the county")
      StatTile(value: delimited(races_within_counts.values.sum), label: "open races in its towns")
      StatTile(value: delimited(towns.size), label: "cities and towns")
      next_election_tile
    end
  end

  def races_elsewhere
    races_within
  end

  def where_it_is
    SideCard(heading: "Where it is") do
      dl(class: "place-facts-list") do
        place_row("State", @county.state)
        place_row("Country", @county.state.country)
      end
    end
  end

  def nearby
    geometric = BoundaryNeighborhood.for(@county).same_layer_neighbors.first(NEIGHBOR_LIMIT)
    neighbors = geometric.presence || @county.state.counties.where.not(id: @county.id).order(:name).limit(NEIGHBOR_LIMIT).to_a
    return if neighbors.empty?

    heading = geometric.present? ? "Adjacent counties" : "Other counties in #{@county.state.name}"
    SideCard(heading: heading) do
      ul(class: "nearby-list") { neighbors.each { |neighbor| li { link_to neighbor.name, neighbor, class: "text-link" } } }
      link_to "All counties in #{@county.state.name}", counties_path(state_id: @county.state_id), class: "text-link"
    end
  end
end

