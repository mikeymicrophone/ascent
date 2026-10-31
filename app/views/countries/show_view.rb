# frozen_string_literal: true

# A country's page: its national races, then counts of the races decided by the states and places within
# it, and every state as a way down to its own page.
class Views::Countries::ShowView < Views::ApplicationView
  include Views::PlaceSections

  prop :country, Country

  def view_template
    div(class: "place-page", id: dom_id(@country, :show)) do
      place_header
      fact_tiles
      div(class: "place-layout") do
        div(class: "place-main") do
          ballot_section
          place_chips("States", states, total: states.size, see_all: country_states_path(@country))
          seats_section
          elections_section
        end
        aside(class: "place-aside", aria: { label: "Admin" }) { admin_actions } if current_voter&.admin?
      end
    end
  end

  private

  def place
    @country
  end

  def trail
    [ [ "Countries", countries_path ] ]
  end

  def eyebrow
    [ "Country", @country.code ].compact_blank.join(" · ")
  end

  def lede
    "#{@country.name} has #{pluralize(states.size, "state")} on Ascent. #{open_races_sentence("national")}"
  end

  def states
    @states ||= @country.states.order(:name).to_a
  end

  def fact_tiles
    div(class: "stat-tiles place-facts") do
      StatTile(value: delimited(open_races.size + races_within_counts.values.sum), label: "open races across the country")
      StatTile(value: delimited(states.size), label: "states")
      StatTile(value: delimited(@country.counties.count), label: "counties")
      next_election_tile
    end
  end

  def races_elsewhere
    races_within
  end
end
