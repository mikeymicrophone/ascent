# frozen_string_literal: true

# A state's page: its statewide races, then counts of the races decided by the counties, towns and
# districts within it, the seats elected statewide, and its elections. The places within it lead on to
# their own pages, so a voter can find their ballot from here.
class Views::States::ShowView < Views::ApplicationView
  include Views::PlaceSections

  CHIP_LIMIT = 24

  prop :state, ::State

  def view_template
    div(class: "place-page", id: dom_id(@state, :show)) do
      place_header
      fact_tiles
      div(class: "place-layout") do
        div(class: "place-main") do
          ballot_section
          place_chips("Counties", counties.first(CHIP_LIMIT), total: counties.size, see_all: counties_path(state_id: @state.id))
          town_finder
          district_kinds
          seats_section
          elections_section
        end
        aside(class: "place-aside", aria: { label: "Around #{@state.name}" }) do
          where_it_is
          boundary_side_card
          admin_actions
        end
      end
    end
  end

  private

  def place
    @state
  end

  def trail
    trail_for(@state)
  end

  def eyebrow
    [ "State", @state.code, @state.country.name ].compact_blank.join(" · ")
  end

  def lede
    [
      "#{@state.name} has #{pluralize(counties.size, "county", plural: "counties")} and #{pluralize(town_count, "city and town", plural: "cities and towns")} on Ascent.",
      open_races_sentence("statewide")
    ].join(" ")
  end

  def counties
    @counties ||= @state.counties.order(:name).to_a
  end

  def town_count
    @town_count ||= @state.municipalities.count
  end

  def districts
    @districts ||= District.in_state(@state)
  end

  def fact_tiles
    div(class: "stat-tiles place-facts") do
      StatTile(value: delimited(open_races.size + races_within_counts.values.sum), label: "open races across the state")
      StatTile(value: delimited(counties.size), label: "counties")
      StatTile(value: delimited(town_count), label: "cities and towns")
      next_election_tile
    end
  end

  def races_elsewhere
    races_within(races_path(state_id: @state.id))
  end

  # Too many towns to list, so a compact search that opens the towns list narrowed to this state.
  def town_finder
    return if town_count.zero?

    section(class: "place-town-finder") do
      div(class: "place-town-finder-heading") do
        h2(class: "place-town-finder-title") { "Cities and towns" }
        span(class: "place-section-subtitle") { delimited(town_count) }
      end
      form(action: municipalities_path, method: "get", role: "search", class: "place-town-finder-form") do
        input(type: "hidden", name: "state_id", value: @state.id)
        label(for: "town-search", class: "visually-hidden") { "Find a city or town in #{@state.name}" }
        input(id: "town-search", type: "search", name: "q", placeholder: "Find a city or town", class: "place-town-finder-input")
        button(type: "submit", class: "place-town-finder-submit") { "Find" }
      end
    end
  end


  # The legislative and judicial districts drawn across the state, counted by kind.
  def district_kinds
    counts = districts.group(:kind).order(count_all: :desc).count
    return if counts.empty?

    section(class: "place-section") do
      section_heading("Districts", delimited(counts.values.sum))
      ul(class: "seat-list") do
        counts.each do |kind, count|
          li(class: "seat-item") do
            link_to kind.capitalize.pluralize, districts_path(state_id: @state.id, kind: kind), class: "seat-title text-link"
            span(class: "seat-count") { delimited(count) }
          end
        end
      end
    end
  end

  def where_it_is
    SideCard(heading: "Where it is") do
      dl(class: "place-facts-list") do
        place_row("Country", @state.country)
        FactRow(label: "Postal code") { @state.code } if @state.code.present?
      end
      if resident?
        link_to ballot_path, class: "text-link" do
          plain "Your ballot here"
          icon(:chevron_right)
        end
      end
    end
  end
end
