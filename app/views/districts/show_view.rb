# frozen_string_literal: true

# A district's page: the seats it elects and their open races, its elections, and the other districts
# of its kind in the same state.
class Views::Districts::ShowView < Views::ApplicationView
  include Views::PlaceSections

  SIBLING_LIMIT = 8

  prop :district, District

  def view_template
    div(class: "place-page", id: dom_id(@district, :show)) do
      place_header
      fact_tiles
      div(class: "place-layout") do
        div(class: "place-main") do
          ballot_section
          seats_section
          elections_section
        end
        aside(class: "place-aside", aria: { label: "Around #{@district.name}" }) do
          where_it_is
          siblings
          admin_actions
        end
      end
    end
  end

  private

  def place
    @district
  end

  def trail
    trail_for(@district)
  end

  # The state or city the district is drawn within.
  def container
    jurisdiction&.parent&.jurisdictionable
  end

  def eyebrow
    [ @district.kind.capitalize, container&.name ].compact.join(" · ")
  end

  def lede
    [ ("#{@district.name} is a #{@district.kind} in #{container.name}." if container), seats_sentence, open_races_sentence ].compact.join(" ")
  end

  def fact_tiles
    div(class: "stat-tiles place-facts") do
      StatTile(value: open_races.size.to_s, label: "open #{"race".pluralize(open_races.size)} decided here")
      seats = @district.office_seats.values.sum
      StatTile(value: seats.to_s, label: "#{"seat".pluralize(seats)} elected here")
      next_election_tile
    end
  end

  def where_it_is
    return unless container

    SideCard(heading: "Where it is") do
      dl(class: "place-facts-list") { place_row(container.model_name.human, container) }
    end
  end

  def siblings
    return unless jurisdiction

    others = District.where(kind: @district.kind, id: Jurisdiction.siblings_of(jurisdiction).where(jurisdictionable_type: "District").select(:jurisdictionable_id))
    shown = others.in_natural_order.limit(SIBLING_LIMIT).to_a
    return if shown.empty?

    SideCard(heading: "Other #{@district.kind.pluralize}") do
      ul(class: "nearby-list") { shown.each { |sibling| li { link_to sibling.name, sibling, class: "text-link" } } }
      if container.is_a?(::State)
        link_to "All #{delimited(others.count + 1)} in #{container.name}", districts_path(state_id: container.id, kind: @district.kind), class: "text-link"
      end
    end
  end
end
