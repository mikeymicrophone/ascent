# frozen_string_literal: true

# My ballot: every open race where the voter lives, from city to federal, with how far they have got on
# each, then the races beyond it they can pretend vote in.
class Views::Ballots::ShowView < Views::ApplicationView
  LEVEL_LABELS = { "city" => "City", "county" => "County", "state" => "State", "federal" => "Federal" }.freeze

  prop :ballot, Ballot
  prop :query, String

  def view_template
    div(class: "ballot-page") do
      ballot_header
      if @ballot.residence
        ballot_levels
      else
        no_residence
      end
      elsewhere
    end
  end

  private

  def ballot_header
    section(class: "ballot-header") do
      div(class: "ballot-intro") do
        span(class: "eyebrow") { election_eyebrow } if @ballot.next_election
        h1(class: "display-title") { "Your ballot" }
        p(class: "ballot-lede") { ballot_lede }
      end
      residence_card if @ballot.residence
    end
  end

  def election_eyebrow
    election = @ballot.next_election
    "#{election.name} · #{election.election_date.strftime("%A, %B %-d")}"
  end

  def ballot_lede
    count = @ballot.mountains.size
    return "No open races where you live right now. Try a pretend vote below." if count.zero?

    "#{pluralize(count, "race")} #{count == 1 ? "is" : "are"} on the ballot where you live. Build a mountain for each: " \
      "rate every candidate, set your baseline, and see who you approve."
  end

  def residence_card
    residence = @ballot.residence
    div(class: "residence-card") do
      div(class: "residence-card-place") do
        span(class: "residence-card-icon") { icon(:map_pin) }
        div(class: "residence-card-text") do
          strong(class: "residence-card-name") { residence.jurisdiction.name }
          span(class: "residence-card-districts") { residence_districts_text(residence) }
        end
        link_to("Change", edit_residence_path(residence), class: "pill-button pill-button-outline") if current_voter.admin?
      end
      progress_bar
    end
  end

  def residence_districts_text(residence)
    [ residence.jurisdiction.parent, *residence.district_jurisdictions ].compact.map(&:name).join(" · ")
  end

  def progress_bar
    counts = @ballot.progress_counts
    div(class: "progress-bar", aria: { hidden: true }) do
      counts.each { |state, count| span(class: "progress-segment progress-#{state.dasherize}", style: "flex-grow: #{count}") if count.positive? }
    end
    div(class: "progress-counts") do
      counts.each do |state, count|
        span(class: "progress-count") do
          strong { count.to_s }
          whitespace
          plain state.humanize(capitalize: false)
        end
      end
    end
  end

  def ballot_levels
    div(class: "ballot-levels") do
      @ballot.levels.each do |level, mountains|
        section(class: "ballot-level") do
          h2(class: "section-rule") { span { LEVEL_LABELS.fetch(level) } }
          div(class: "race-card-grid") do
            mountains.each { Views::Ballots::RaceCard(mountain: it) }
          end
        end
      end
    end
  end

  def no_residence
    section(class: "ballot-empty") do
      h2(class: "card-title") { "We don't know where you vote yet" }
      p { "Your ballot comes from where you live. Until it's recorded, you can still pretend vote in any race below." }
      link_to("Record a residence", new_residence_path, class: "pill-button") if current_voter.admin?
    end
  end

  def elsewhere
    section(class: "elsewhere", id: "elsewhere") do
      div(class: "elsewhere-header") do
        div(class: "elsewhere-intro") do
          span(class: "eyebrow") do
            icon(:compass)
            plain "Beyond your ballot"
          end
          h2(class: "display-subtitle") { "Pretend vote anywhere" }
          p(class: "elsewhere-lede") do
            "Build a mountain for a race you can't vote in, or try a mock or historical election. " \
              "Pretend mountains are counted apart from residents' and are always labelled."
          end
        end
        search_form
      end
      search_results if @query.present?
      suggestion_cards
    end
  end

  def search_form
    form(action: ballot_path(anchor: "elsewhere"), method: "get", role: "search", class: "place-search") do
      label(for: "place-search", class: "place-search-label") { "Find a place or race" }
      div(class: "place-search-row") do
        input(id: "place-search", type: "search", name: "q", value: @query, placeholder: "City, county, district or office", class: "place-search-input")
        button(type: "submit", class: "pill-button") { "Search" }
      end
    end
  end

  def search_results
    races = @ballot.pretend_races(@query).with_naming_details.limit(12)
    div(class: "elsewhere-results") do
      if races.any?
        div(class: "suggestion-grid") { races.each { suggestion_card(it, "pretend") } }
      else
        p(class: "elsewhere-none") { "No open races match “#{@query}”." }
      end
    end
  end

  def suggestion_cards
    div(class: "suggestion-grid") do
      @ballot.neighboring_races.with_naming_details.limit(3).each { suggestion_card(it, "pretend") }
      @ballot.mock_races.with_naming_details.limit(3).each { suggestion_card(it, "mock") }
      @ballot.historical_races.with_naming_details.limit(3).each { suggestion_card(it, "historical") }
      link_to new_mock_election_path, class: "suggestion-card suggestion-new" do
        span(class: "suggestion-chip") { "New" }
        strong(class: "suggestion-title") { "Make a mock election" }
        span(class: "suggestion-meta") { "Invent a race for a class or a test" }
      end
    end
  end

  def suggestion_card(race, mode)
    link_to edit_mountain_path(race), class: "suggestion-card suggestion-#{mode}" do
      span(class: "suggestion-chip") { { "pretend" => "Pretend vote", "mock" => "Mock election", "historical" => "Historical" }.fetch(mode) }
      strong(class: "suggestion-title") { race.office.name }
      span(class: "suggestion-meta") { "#{race.election.name} · #{pluralize(race.candidacies.size, "candidate")}" }
    end
  end
end
