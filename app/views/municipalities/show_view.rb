# frozen_string_literal: true

# A city's page: what it is and where it sits, what is on its ballot now, the seats it elects, and its
# elections. The first call to action fits the visitor: their own ballot if they live here, a pretend
# vote if they don't, or signing in. Related records are trimmed to what helps the next step.
class Views::Municipalities::ShowView < Views::ApplicationView
  RACE_LIMIT = 6
  SEAT_LIMIT = 8
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
        aside(class: "place-aside", aria: { label: "Around #{name}" }) do
          where_it_is
          nearby
          admin_actions
        end
      end
    end
  end

  private

  def name
    @municipality.name
  end

  def jurisdiction
    @municipality.jurisdiction
  end

  def resident?
    current_voter && jurisdiction && current_voter.lives_in?(jurisdiction)
  end

  def open_races
    @open_races ||= @municipality.open_local_races.with_naming_details.to_a
  end

  def next_election
    @next_election ||= @municipality.next_election
  end

  # Header: where it sits, what it is, one primary action, then bookmarks and sharing.
  def place_header
    section(class: "place-header") do
      breadcrumb
      span(class: "eyebrow") { [ "City", @municipality.distinct_county&.name, @municipality.state.name ].compact.join(" · ") }
      h1(class: "display-title") { name }
      p(class: "ballot-lede") { lede }
      div(class: "place-actions") do
        primary_action
        secondary_action
      end
      ActionBar(record: @municipality)
    end
  end

  def breadcrumb
    nav(class: "breadcrumb", aria: { label: "Breadcrumb" }) do
      [ @municipality.state.country, @municipality.state, @municipality.distinct_county ].compact.each do |place|
        link_to place.name, place, class: "breadcrumb-link"
        span(class: "breadcrumb-separator", aria: { hidden: true }) { "/" }
      end
      span(aria: { current: "page" }) { name }
    end
  end

  def lede
    seats = @municipality.office_seats.values.sum
    [
      "#{name} is in #{[ @municipality.distinct_county&.name, @municipality.state.name ].compact.join(", ")}.",
      ("#{pluralize(seats, "seat")} #{seats == 1 ? "is" : "are"} elected here." if seats.positive?),
      (open_races.any? ? "#{pluralize(open_races.size, "race")} #{open_races.size == 1 ? "is" : "are"} open on the #{next_election.name}." : "No races are open here right now.")
    ].compact.join(" ")
  end

  def primary_action
    if resident?
      link_to ballot_path, class: "pill-button" do
        icon(:map_pin)
        plain "Open my ballot"
      end
    elsif !current_voter
      link_to "Sign in to build a mountain", new_voter_session_path, class: "pill-button"
    elsif open_races.any?
      link_to "#place-ballot", class: "pill-button pill-button-summit" do
        icon(:compass)
        plain "Pretend vote here"
      end
    else
      mock_election_link("pill-button")
    end
  end

  def secondary_action
    if open_races.any? && (resident? || !current_voter)
      link_to "See the races here", "#place-ballot", class: "pill-button pill-button-outline"
    elsif current_voter && open_races.any?
      mock_election_link("pill-button pill-button-outline")
    end
  end

  def mock_election_link(classes)
    link_to new_mock_election_path(jurisdiction_id: jurisdiction&.id), class: classes do
      icon(:flask_conical)
      plain "Make a mock election here"
    end
  end

  def fact_tiles
    div(class: "stat-tiles place-facts") do
      fact(open_races.size.to_s, "open #{"race".pluralize(open_races.size)} decided here")
      seats = @municipality.office_seats.values.sum
      fact(seats.to_s, "#{"seat".pluralize(seats)} elected here")
      if next_election
        fact(next_election.election_date.strftime("%b %-d"), election_day_label, modifier: "date")
      end
      fact(@municipality.voters.count.to_s, "voters here on Ascent")
    end
  end

  def election_day_label
    days = next_election.days_until
    days.positive? ? "election day · in #{pluralize(days, "day")}" : "election day"
  end

  def fact(value, label, modifier: nil)
    div(class: "stat-tile#{" stat-tile-#{modifier}" if modifier}") do
      span(class: "stat-tile-value") { value }
      span(class: "stat-tile-label") { label }
    end
  end

  # The open races decided here, then a line for the races every resident also votes in.
  def ballot_section
    section(class: "place-section", id: "place-ballot") do
      section_heading("On the ballot here", next_election && "#{next_election.name} · #{next_election.election_date.strftime("%A, %B %-d")}")
      if open_races.any?
        div(class: "place-race-grid") { open_races.first(RACE_LIMIT).each { place_race(it) } }
        more_races_link if open_races.size > RACE_LIMIT
        races_above
      else
        p(class: "card-text") { "Nothing is open for a vote here right now. Past elections are below." }
      end
    end
  end

  def place_race(race)
    article(class: "place-race") do
      div(class: "place-race-heading") do
        h3(class: "place-race-office") { race.office.position.title }
        span(class: "place-race-seat") { seat_label(race.office) } if race.office.seat_code.present?
      end
      span(class: "race-card-meta") { "#{pluralize(race.candidacies.size, "candidate")} · #{race.status.humanize}" }
      div(class: "race-card-actions") do
        link_to("Results", race_results_path(race), class: "race-card-link")
        link_to edit_mountain_path(race), class: "pill-button race-card-cta" do
          plain(resident? ? "Build your mountain" : "Pretend vote")
          icon(:chevron_right)
        end
      end
    end
  end

  # DISTRICT_10 reads as "District 10", AT_LARGE as "At large".
  def seat_label(office)
    office.seat_code.humanize
  end

  def more_races_link
    link_to races_path(election_id: next_election.id), class: "text-link" do
      plain "See all #{open_races.size} races"
      icon(:chevron_right)
    end
  end

  def races_above
    counts = @municipality.open_races_above.includes(office: :jurisdiction).group_by { it.office.jurisdiction.ballot_level }
      .transform_values(&:size).sort_by { |level, _| Jurisdiction::BALLOT_LEVELS.index(level) }
    return if counts.empty?

    div(class: "races-above") do
      span(class: "races-above-label") { "Also on every ballot here" }
      counts.each { |level, count| span(class: "races-above-count") { pluralize(count, "#{level} race") } }
      link_to("See them on my ballot", ballot_path, class: "text-link") if resident?
    end
  end

  # The seats elected here, grouped by position, with the long tail folded into a count.
  def seats_section
    seats = @municipality.office_seats
    return if seats.empty?

    section(class: "place-section") do
      section_heading("Seats elected here", nil)
      ul(class: "seat-list") do
        seats.first(SEAT_LIMIT).each do |title, count|
          li(class: "seat-item") do
            span(class: "seat-title") { title }
            span(class: "seat-count") { pluralize(count, "seat") }
          end
        end
      end
      p(class: "card-text") { "And #{pluralize(seats.size - SEAT_LIMIT, "more position")}." } if seats.size > SEAT_LIMIT
    end
  end

  # Upcoming elections in full, and only the three most recent finished ones.
  def elections_section
    upcoming = @municipality.upcoming_elections.to_a
    past = @municipality.past_elections.limit(3).to_a
    return if upcoming.empty? && past.empty?

    section(class: "place-section") do
      section_heading("Elections", nil)
      ol(class: "election-timeline") do
        (upcoming + past).each { election_item(it) }
      end
    end
  end

  def election_item(election)
    li(class: "timeline-item timeline-#{election.status}") do
      span(class: "timeline-date") { election.election_date.strftime("%b %-d, %Y") }
      link_to election.name, election, class: "timeline-name"
      span(class: "race-status-chip race-status-#{election.status}") { election.status }
    end
  end

  def section_heading(title, subtitle)
    div(class: "place-section-heading") do
      h2(class: "card-title") { title }
      span(class: "place-section-subtitle") { subtitle } if subtitle
    end
  end

  # Where the city sits, and the wards or districts within it.
  def where_it_is
    section(class: "side-card") do
      h2(class: "card-heading") { "Where it is" }
      dl(class: "place-facts-list") do
        place_row("State", @municipality.state)
        place_row("County", @municipality.distinct_county) if @municipality.distinct_county
        place_row("Country", @municipality.state.country)
      end
      within_here
    end
  end

  def place_row(label, place)
    div(class: "place-fact-row") do
      dt { label }
      dd { link_to place.name, place, class: "text-link" }
    end
  end

  def within_here
    districts = jurisdiction ? jurisdiction.children.includes(:jurisdictionable).sort_by(&:name) : []
    return if districts.empty?

    div(class: "within-here") do
      span(class: "card-heading") { "Within #{name}" }
      ul(class: "chip-list") { districts.each { |district| li(class: "place-chip") { district.name } } }
    end
  end

  def nearby
    neighbors = @municipality.neighbors.limit(NEIGHBOR_LIMIT).to_a
    return if neighbors.empty?

    section(class: "side-card") do
      h2(class: "card-heading") { "Nearby in #{@municipality.county.name}" }
      ul(class: "nearby-list") do
        neighbors.each { |neighbor| li { link_to neighbor.name, neighbor, class: "text-link" } }
      end
      if @municipality.neighbors.count > NEIGHBOR_LIMIT
        link_to "All places in #{@municipality.state.name}", municipalities_path(state_id: @municipality.state_id), class: "text-link"
      end
    end
  end

  def admin_actions
    return unless current_voter&.admin?

    section(class: "side-card admin-card") do
      h2(class: "card-heading") { "Admin" }
      Ui::ResourceActions(resource: @municipality)
    end
  end
end
