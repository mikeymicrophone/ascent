# frozen_string_literal: true

# The sections every place's page shares: a header whose first action fits the visitor, what is on the
# ballot here, the seats elected here, and the elections held here, with a side card of where it sits.
# A page that includes it defines `place`, `trail`, `eyebrow` and `lede`, and may define
# `races_elsewhere` to follow the ballot with the races decided above or within the place.
module Views::PlaceSections
  RACE_LIMIT = 6
  SEAT_LIMIT = 8
  # How each kind of place below this one is counted, in ballot order.
  WITHIN_LABELS = { "State" => "state", "County" => "county", "Municipality" => "city and town", "District" => "district" }.freeze

  private

  def jurisdiction
    place.jurisdiction
  end

  def resident?
    return @resident if defined?(@resident)

    @resident = (current_voter && jurisdiction && current_voter.lives_in?(jurisdiction)) || false
  end

  def open_races
    @open_races ||= place.open_local_races.with_naming_details.includes(:candidacies).to_a
  end

  def next_election
    return @next_election if defined?(@next_election)

    @next_election = place.next_election
  end

  def place_header
    PageHeader(title: place.name, trail: trail, eyebrow: eyebrow, lede: lede, record: place, icon_for: place, modifier: "place-header") do
      primary_action
      secondary_action
    end
  end

  def primary_action
    if resident?
      PillLink(label: "Open my ballot", path: ballot_path, icon: :map_pin)
    elsif !current_voter
      PillLink(label: "Sign in to build a mountain", path: new_voter_session_path)
    elsif open_races.any?
      PillLink(label: "Pretend vote here", path: "#place-ballot", icon: :compass, variant: "summit")
    else
      mock_election_link("pill-button")
    end
  end

  def secondary_action
    if open_races.any? && (resident? || !current_voter)
      PillLink(label: "See the races here", path: "#place-ballot", variant: "outline")
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

  # "3 statewide races are open on the Virginia General Election 2026.", or that none is open.
  def open_races_sentence(kind = nil)
    noun = [ kind, "race" ].compact.join(" ")
    return "No #{noun.pluralize} are open#{" here" unless kind} right now." if open_races.empty?

    "#{pluralize(open_races.size, noun)} #{open_races.size == 1 ? "is" : "are"} open on the #{next_election.name}."
  end

  def races_within_counts
    @races_within_counts ||= place.open_races_within
  end

  def seats_sentence
    seats = place.office_seats.values.sum
    "#{pluralize(seats, "seat")} #{seats == 1 ? "is" : "are"} elected here." if seats.positive?
  end

  def next_election_tile
    return unless next_election

    days = next_election.days_until
    StatTile(value: next_election.election_date.strftime("%b %-d"), modifier: "date",
      label: days.positive? ? "election day · in #{pluralize(days, "day")}" : "election day")
  end

  # The open races decided here, then whatever the page adds about races above or within it.
  def ballot_section
    section(class: "place-section", id: "place-ballot") do
      section_heading("On the ballot here", next_election && "#{next_election.name} · #{next_election.election_date.strftime("%A, %B %-d")}")
      if open_races.any?
        div(class: "place-race-grid") { open_races.first(RACE_LIMIT).each { place_race(it) } }
        more_races_link if open_races.size > RACE_LIMIT
      else
        p(class: "card-text") { "Nothing decided here is open for a vote right now." }
      end
      races_elsewhere
    end
  end

  def races_elsewhere
  end

  def place_race(race)
    article(class: "place-race") do
      div(class: "place-race-heading") do
        h3(class: "place-race-office") { link_to race.office.position.title, race, class: "place-race-link" }
        span(class: "place-race-seat") { race.office.seat_label } if race.office.seat_code.present?
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

  def more_races_link
    link_to races_path(election_id: next_election.id), class: "text-link" do
      plain "See all #{open_races.size} races"
      icon(:chevron_right)
    end
  end

  # Open races decided by the places within this one, as counts by kind of place.
  def races_within(see_all = nil)
    counts = races_within_counts.sort_by { |type, _| WITHIN_LABELS.keys.index(type) || WITHIN_LABELS.size }
    return if counts.empty?

    div(class: "races-above") do
      span(class: "races-above-label") { "Also open within #{place.name}" }
      counts.each { |type, count| span(class: "races-above-count") { "#{delimited(count)} #{WITHIN_LABELS.fetch(type, type.downcase)} #{"race".pluralize(count)}" } }
      link_to("See them all", see_all, class: "text-link") if see_all
    end
  end

  # The seats elected here, grouped by position, with the long tail folded into a count.
  def seats_section
    seats = place.office_seats
    return if seats.empty?

    section(class: "place-section") do
      section_heading("Seats elected here")
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
    upcoming = place.upcoming_elections.to_a
    past = place.past_elections.limit(3).to_a
    return if upcoming.empty? && past.empty?

    section(class: "place-section") do
      section_heading("Elections")
      ol(class: "election-timeline") do
        (upcoming + past).each { election_item(it) }
      end
    end
  end

  def election_item(election)
    li(class: "timeline-item timeline-#{election.status}") do
      span(class: "timeline-date") { election.election_date.strftime("%b %-d, %Y") }
      link_to election.name, election, class: "timeline-name"
      StatusChip(status: election.status)
    end
  end

  def place_row(label, other_place)
    FactRow(label: label) { link_to other_place.name, other_place, class: "text-link" }
  end

  # A few places of one kind within this one, as chips, with a link to all of them.
  def place_chips(heading, places, total:, see_all:)
    return if total.zero?

    section(class: "place-section") do
      section_heading(heading, delimited(total))
      ul(class: "chip-list place-chip-links") { places.each { |other| li { link_to other.name, other, class: "place-chip place-chip-link" } } }
      if total > places.size
        link_to see_all, class: "text-link" do
          plain "See all #{delimited(total)}"
          icon(:chevron_right)
        end
      end
    end
  end

  def admin_actions
    return unless current_voter&.admin?

    SideCard(heading: "Admin", modifier: "admin-card") do
      Ui::ResourceActions(resource: place)
    end
  end
end
