# frozen_string_literal: true

# An election's page, built around two things only an election has: a date and a ballot. The date is a
# stub with a countdown strip of the days left; the ballot is a numbered sheet of contests in printed
# order, where offices with several seats collapse into seat chips that show the voter's own progress.
class Views::Elections::ShowView < Views::ApplicationView
  CONTEST_LIMIT = 10
  CANDIDATE_NAME_LIMIT = 4
  DAY_CELL_LIMIT = 45

  prop :election, Election

  def view_template
    div(class: "election-page", id: dom_id(@election, :show)) do
      election_strip
      election_hero
      div(class: "election-layout") do
        ballot_sheet
        aside(class: "election-aside", aria: { label: "About this election" }) do
          at_a_glance
          where_held
          before_and_after
          admin_actions
        end
      end
    end
  end

  private

  def mode
    @mode ||= if @election.mode != "real" then @election.mode
    elsif current_voter&.lives_in?(@election.jurisdiction) then "ballot"
    else "pretend"
    end
  end

  def place
    @election.jurisdiction.jurisdictionable
  end

  def contests
    @contests ||= @election.contests
  end

  def progress
    @progress ||= current_voter ? current_voter.mountain_progress(@election.races) : {}
  end

  def election_strip
    labels = {
      "ballot" => [ "Your ballot", "You live in #{place.name}; these races are yours to vote in" ],
      "pretend" => [ "Pretend vote", "You don't live in #{place.name}. Mountains you build here count with visitors" ],
      "mock" => [ "Mock election", "Invented candidates#{" · made by #{@election.creator.first_name}" if @election.creator}" ],
      "historical" => [ "Historical · #{@election.election_date.year}", "This election is over; replay its races with approval" ]
    }
    label, text = labels.fetch(mode)
    div(class: "mode-strip mode-#{mode}", role: "status") do
      div(class: "mode-strip-inner") do
        div(class: "mode-strip-main") do
          span(class: "mode-strip-label") { label }
          span(class: "mode-strip-text") { text }
        end
        span(class: "mode-strip-note") { "Not a real race" } if mode == "mock"
      end
    end
  end

  # Hero: the name and one action on the left, the date stub and countdown on the right.
  def election_hero
    section(class: "election-hero") do
      div(class: "election-hero-text") do
        nav(class: "breadcrumb", aria: { label: "Breadcrumb" }) do
          link_to "Elections", elections_path, class: "breadcrumb-link"
          span(class: "breadcrumb-separator", aria: { hidden: true }) { "/" }
          link_to place.name, place, class: "breadcrumb-link"
        end
        span(class: "eyebrow") { [ @election.kind&.humanize, "election", place.name ].compact.join(" · ") }
        h1(class: "display-title") { @election.name }
        p(class: "ballot-lede") { lede }
        div(class: "place-actions") do
          primary_action
          remove_mock_action
        end
        ActionBar(record: @election)
      end
      date_stub
    end
  end

  def lede
    seats = @election.races.size
    candidates = contests.sum { |_, contest_races| contest_races.sum { it.candidacies.size } }
    [
      "#{pluralize(contests.size, "contest")} across #{pluralize(seats, "seat")}, with #{pluralize(candidates, "candidate")}.",
      @election.description.presence
    ].compact.join(" ")
  end

  def primary_action
    if !current_voter
      link_to "Sign in to build a mountain", new_voter_session_path, class: "pill-button"
    elsif mode == "ballot" && @election.open_to_rating?
      link_to ballot_path, class: "pill-button" do
        icon(:map_pin)
        plain "Open my ballot"
      end
    elsif @election.open_to_rating? || mode == "historical"
      link_to "#election-ballot", class: "pill-button pill-button-summit" do
        icon(mode == "historical" ? :clock : :compass)
        plain({ "pretend" => "Pretend vote here", "mock" => "Build your mountains", "historical" => "Replay with approval" }.fetch(mode, "See the ballot"))
      end
    else
      link_to "See the ballot", "#election-ballot", class: "pill-button pill-button-outline"
    end
  end

  def remove_mock_action
    return unless @election.is_mock && allowed_to?(:destroy?, @election, with: MockElectionPolicy, context: { voter: current_voter })

    button_to "Remove mock election", mock_election_path(@election), method: :delete, class: "pill-button pill-button-ghost",
      form_class: "inline-form", data: { turbo_confirm: "Remove this mock election and its invented candidates?" }
  end

  # The stub: day numeral, month and weekday, and a strip with one cell per day left (or per week, when
  # the election is far off), early voting shaded and election day marked lime.
  def date_stub
    date = @election.election_date
    div(class: "date-stub") do
      div(class: "date-stub-top") do
        span(class: "date-stub-month") { date.strftime("%b") }
        span(class: "date-stub-day") { date.strftime("%-d") }
        span(class: "date-stub-weekday") { date.strftime("%A %Y") }
      end
      div(class: "date-stub-bottom") do
        span(class: "date-stub-countdown") { countdown_text }
        countdown_strip if @election.days_until.positive?
        early_voting_note
      end
    end
  end

  def countdown_text
    days = @election.days_until
    if days.positive? then "#{pluralize(days, "day")} to go"
    elsif days.zero? then "Election day is today"
    else "Held #{pluralize(-days, "day")} ago"
    end
  end

  def countdown_strip
    days = @election.days_until
    weekly = days > DAY_CELL_LIMIT
    dates = weekly ? (0..(days / 7)).map { Date.current + it.weeks } : (0..days).map { Date.current + it }
    div(class: "countdown-strip#{" is-weekly" if weekly}", aria: { hidden: true }) do
      dates.each { |date| span(class: "countdown-cell #{cell_state(date, weekly)}", title: date.strftime("%a %b %-d")) }
    end
    span(class: "countdown-scale") { weekly ? "One square per week" : "One square per day" }
  end

  def cell_state(date, weekly)
    if election_day_cell?(date, weekly) then "is-election-day"
    elsif date == Date.current then "is-today"
    elsif early_voting?(date) then "is-early-voting"
    else ""
    end
  end

  # A weekly square holds election day when it falls in the same week.
  def election_day_cell?(date, weekly)
    election_day = @election.election_date
    weekly ? date.cweek == election_day.cweek && date.cwyear == election_day.cwyear : date == election_day
  end

  def early_voting?(date)
    @election.early_voting_starts_on && @election.early_voting_ends_on && date.between?(@election.early_voting_starts_on, @election.early_voting_ends_on)
  end

  def early_voting_note
    return unless @election.early_voting_starts_on || @election.early_voting_ends_on

    span(class: "date-stub-note") do
      "Early voting #{[ @election.early_voting_starts_on, @election.early_voting_ends_on ].map { it&.strftime("%b %-d") || "TBD" }.join(" – ")}"
    end
  end

  # The ballot sheet: numbered contests, the first ten open, the rest folded away.
  def ballot_sheet
    section(class: "ballot-sheet", id: "election-ballot", aria: { label: "The ballot" }) do
      div(class: "ballot-sheet-head") do
        h2(class: "ballot-sheet-title") { "The ballot" }
        span(class: "ballot-sheet-meta") { "#{pluralize(contests.size, "contest")} · in printed order, federal to local" }
      end
      if contests.empty?
        p(class: "card-text ballot-sheet-empty") { "No races have been added to this election yet." }
      else
        ol(class: "contest-list") { contests.first(CONTEST_LIMIT).each_with_index { |contest, index| contest_row(contest, index) } }
        more_contests if contests.size > CONTEST_LIMIT
      end
      progress_key if progress.any?
    end
  end

  def more_contests
    details(class: "more-contests") do
      summary(class: "more-contests-toggle") { "Show #{pluralize(contests.size - CONTEST_LIMIT, "more contest")}" }
      ol(class: "contest-list", start: CONTEST_LIMIT + 1) do
        contests.drop(CONTEST_LIMIT).each_with_index { |contest, index| contest_row(contest, index + CONTEST_LIMIT) }
      end
    end
  end

  def contest_row(contest, index)
    (level, title), contest_races = contest
    li(class: "contest") do
      span(class: "contest-number") { (index + 1).to_s.rjust(2, "0") }
      div(class: "contest-body") do
        div(class: "contest-head") do
          h3(class: "contest-title") { title }
          span(class: "contest-level") { level }
          span(class: "contest-meta") { contest_meta(contest_races) }
        end
        contest_races.one? ? single_seat(contest_races.first) : seat_chips(contest_races)
      end
    end
  end

  def contest_meta(contest_races)
    candidates = contest_races.sum { it.candidacies.size }
    [ (pluralize(contest_races.size, "seat") if contest_races.many?), pluralize(candidates, "candidate") ].compact.join(" · ")
  end

  def single_seat(race)
    div(class: "contest-single") do
      p(class: "contest-candidates") { candidate_names(race) }
      div(class: "race-card-actions") do
        progress_chip(race)
        link_to("Results", race_results_path(race), class: "race-card-link")
        link_to(cta_text(race), edit_mountain_path(race), class: "pill-button race-card-cta") if rateable?
      end
    end
  end

  def candidate_names(race)
    names = race.candidacies.reject(&:primary_candidacy_id).map { it.person.full_name }
    return "No candidates yet" if names.empty?

    shown = names.first(CANDIDATE_NAME_LIMIT).join(", ")
    names.size > CANDIDATE_NAME_LIMIT ? "#{shown}, and #{names.size - CANDIDATE_NAME_LIMIT} more" : shown
  end

  def seat_chips(contest_races)
    ul(class: "seat-chips") do
      contest_races.sort_by { seat_order(it) }.each_with_index do |race, index|
        label = seat_label(race) || "Seat #{index + 1}"
        li do
          link_to edit_mountain_path(race), class: "seat-chip seat-chip-#{progress.fetch(race.id, "untouched")}",
            title: "#{label}: #{candidate_names(race)}" do
            span(class: "seat-chip-label") { label }
            span(class: "seat-chip-count") { race.candidacies.size.to_s }
          end
        end
      end
    end
  end

  # Seats in natural order, so Group 7 comes before Group 13.
  def seat_order(race)
    label = seat_label(race).to_s
    [ label.gsub(/\d+/, ""), label[/\d+/].to_i, race.id ]
  end

  # A seat reads as its code ("District 3"), or its district when the office sits below the election;
  # nil leaves it to be numbered.
  def seat_label(race)
    office = race.office
    office.seat_code&.humanize || (office.jurisdiction.name unless office.jurisdiction_id == @election.jurisdiction_id)
  end

  def progress_chip(race)
    state = progress[race.id]
    span(class: "state-chip state-chip-#{state}") { state.humanize } if state
  end

  def progress_key
    div(class: "progress-key") do
      span(class: "seat-chip seat-chip-saved key-swatch") { "Saved" }
      span(class: "seat-chip seat-chip-started key-swatch") { "Started" }
      span(class: "seat-chip seat-chip-untouched key-swatch") { "Not started" }
    end
  end

  def rateable?
    @election.open_to_rating? || mode == "historical"
  end

  def cta_text(race)
    case progress[race.id]
    when "saved" then "Open mountain"
    when "started" then "Keep going"
    else { "ballot" => "Build your mountain", "pretend" => "Pretend vote", "mock" => "Build your mountain", "historical" => "Replay" }.fetch(mode)
    end
  end

  def at_a_glance
    section(class: "side-card") do
      h2(class: "card-heading") { "At a glance" }
      dl(class: "place-facts-list") do
        glance_row("Contests", contests.size)
        glance_row("Seats", @election.races.size)
        glance_row("Candidates", contests.sum { |_, contest_races| contest_races.sum { it.candidacies.size } })
        glance_row("Mountains built", @election.mountain_count)
        glance_row("Voters taking part", @election.participant_count)
      end
    end
  end

  def glance_row(label, value)
    div(class: "place-fact-row") do
      dt { label }
      dd(class: "glance-value") { ActiveSupport::NumberHelper.number_to_delimited(value) }
    end
  end

  def where_held
    section(class: "side-card") do
      h2(class: "card-heading") { "Where" }
      dl(class: "place-facts-list") do
        div(class: "place-fact-row") do
          dt { place.class.model_name.human }
          dd { link_to place.name, place, class: "text-link" }
        end
        div(class: "place-fact-row") do
          dt { "Year" }
          dd { link_to @election.year.name.to_s, @election.year, class: "text-link" }
        end
      end
    end
  end

  def before_and_after
    previous = @election.previous_in_jurisdiction
    following = @election.next_in_jurisdiction
    return unless previous || following

    section(class: "side-card") do
      h2(class: "card-heading") { "Before and after in #{place.name}" }
      ul(class: "sibling-elections") do
        sibling_election("Before", previous) if previous
        sibling_election("After", following) if following
      end
    end
  end

  def sibling_election(label, election)
    li(class: "sibling-election") do
      span(class: "sibling-label") { "#{label} · #{election.election_date.strftime("%b %-d, %Y")}" }
      link_to election.name, election, class: "text-link"
    end
  end

  def admin_actions
    return unless current_voter&.admin?

    section(class: "side-card admin-card") do
      h2(class: "card-heading") { "Admin" }
      Ui::ResourceActions(resource: @election)
      scaffold_new_resource_link "Add a race", new_race_path(election_id: @election.id), record: Race
    end
  end
end
