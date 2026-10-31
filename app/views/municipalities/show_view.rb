# frozen_string_literal: true

# A city's page: what it is and where it sits, what is on its ballot now, the seats it elects, and its
# elections. The first call to action fits the visitor: their own ballot if they live here, a pretend
# vote if they don't, or signing in. Related records are trimmed to what helps the next step.
class Views::Municipalities::ShowView < Views::ApplicationView
  include Views::PlaceSections

  NEIGHBOR_LIMIT = 8

  prop :municipality, Municipality

  def view_template
    div(class: "place-page", id: dom_id(@municipality, :show)) do
      place_header
      fact_tiles
      div(class: "place-layout") do
        div(class: "place-main") do
          ballot_section
          seats_section
          elections_section
        end
        aside(class: "place-aside", aria: { label: "Around #{place.name}" }) do
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
    @municipality
  end

  def trail
    trail_for(@municipality)
  end

  def eyebrow
    [ "City", @municipality.distinct_county&.name, @municipality.state.name ].compact.join(" · ")
  end

  def lede
    [
      "#{place.name} is in #{[ @municipality.distinct_county&.name, @municipality.state.name ].compact.join(", ")}.",
      seats_sentence,
      open_races_sentence
    ].compact.join(" ")
  end

  def fact_tiles
    div(class: "stat-tiles place-facts") do
      StatTile(value: open_races.size.to_s, label: "open #{"race".pluralize(open_races.size)} decided here")
      seats = @municipality.office_seats.values.sum
      StatTile(value: seats.to_s, label: "#{"seat".pluralize(seats)} elected here")
      next_election_tile
      StatTile(value: @municipality.voters.count.to_s, label: "voters here on Ascent")
    end
  end

  # The races every resident also votes in, decided by the city, county, state or country above.
  def races_elsewhere
    return if open_races.empty?

    counts = @municipality.open_races_above.includes(office: :jurisdiction).group_by { it.office.jurisdiction.ballot_level }
      .transform_values(&:size).sort_by { |level, _| Jurisdiction::BALLOT_LEVELS.index(level) }
    return if counts.empty?

    div(class: "races-above") do
      span(class: "races-above-label") { "Also on every ballot here" }
      counts.each { |level, count| span(class: "races-above-count") { pluralize(count, "#{level} race") } }
      link_to("See them on my ballot", ballot_path, class: "text-link") if resident?
    end
  end

  # Where the city sits, and the wards or districts within it.
  def where_it_is
    SideCard(heading: "Where it is") do
      dl(class: "place-facts-list") do
        place_row("State", @municipality.state)
        place_row("County", @municipality.distinct_county) if @municipality.distinct_county
        place_row("Country", @municipality.state.country)
      end
      within_here
    end
  end

  def within_here
    districts = jurisdiction ? jurisdiction.children.includes(:jurisdictionable).sort_by(&:name) : []
    return if districts.empty?

    div(class: "within-here") do
      span(class: "card-heading") { "Within #{place.name}" }
      ul(class: "chip-list") { districts.each { |district| li(class: "place-chip") { district.name } } }
    end
  end

  def nearby
    neighbors = @municipality.neighbors.limit(NEIGHBOR_LIMIT).to_a
    return if neighbors.empty?

    SideCard(heading: "Nearby in #{@municipality.county.name}") do
      ul(class: "nearby-list") do
        neighbors.each { |neighbor| li { link_to neighbor.name, neighbor, class: "text-link" } }
      end
      if @municipality.neighbors.count > NEIGHBOR_LIMIT
        link_to "All places in #{@municipality.county.name}", municipalities_path(county_id: @municipality.county_id), class: "text-link"
      end
    end
  end
end
