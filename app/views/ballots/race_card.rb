# frozen_string_literal: true

# One race on My ballot: the office, how many are running, and how far the voter has got.
class Views::Ballots::RaceCard < Views::ApplicationView
  STATES = {
    "saved" => { chip: "Saved", action: "Open mountain" },
    "started" => { chip: "Started", action: "Keep going" },
    "not_started" => { chip: "Not started", action: "Start rating" }
  }.freeze

  prop :mountain, Mountain

  def view_template
    article(class: "race-card race-card-#{progress.dasherize}") do
      div(class: "race-card-top") do
        div(class: "race-card-heading") do
          h3(class: "race-card-office") { race.office.position.title }
          span(class: "race-card-meta") { race_meta }
        end
        span(class: "state-chip state-chip-#{progress.dasherize}") { STATES.dig(progress, :chip) }
      end
      div(class: "race-card-bottom") do
        span(class: "race-card-status") { status_text }
        div(class: "race-card-actions") do
          link_to("Results", race_results_path(race), class: "race-card-link")
          link_to edit_mountain_path(race), class: "pill-button race-card-cta" do
            plain STATES.dig(progress, :action)
            icon(:chevron_right)
          end
        end
      end
    end
  end

  private

  def race
    @mountain.race
  end

  def progress
    @mountain.progress
  end

  def race_meta
    primaries = race.candidacies.from_primaries.count
    [ race.office.jurisdiction.name, "#{@mountain.ballot_candidacies_count} on the ballot",
      ("#{primaries} ran in primaries" if primaries.positive?) ].compact.join(" · ")
  end

  def status_text
    count = @mountain.ballot_candidacies_count
    case progress
    when "saved" then "You approve #{@mountain.approved_candidacies.size} of #{count}"
    when "started" then [ "#{@mountain.rated_count} of #{count} rated", ("unsaved" if @mountain.unsaved?) ].compact.join(" · ")
    else "#{pluralize(count, "candidate")} to rate"
    end
  end
end
