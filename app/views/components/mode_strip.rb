# frozen_string_literal: true

# The strip under the navigation on every race, mountain and result: which election the voter is in,
# and what their mountain counts toward. Modes differ by fill, border and label, never by hue alone.
class Views::Components::ModeStrip < Views::ApplicationView
  prop :race, Race
  prop :voter, _Nilable(Voter)

  def view_template
    ModeBanner(mode: mode, label: mode_label, text: mode_text, icon: mode_icon) { mode_aside }
  end

  private

  def mode
    @voter ? @race.mode_for(@voter) : @race.election.mode
  end

  def election
    @race.election
  end

  def mode_icon
    { "ballot" => :map_pin, "real" => :map_pin, "pretend" => :compass, "mock" => :flask_conical, "historical" => :clock }.fetch(mode)
  end

  def mode_label
    case mode
    when "ballot" then "Your ballot"
    when "real" then "Real election"
    when "pretend" then "Pretend vote"
    when "mock" then "Mock election"
    when "historical" then "Historical · #{election.election_date.year}"
    end
  end

  def mode_text
    case mode
    when "ballot" then "Real election · you live in #{@voter.current_residence.jurisdiction.name}"
    when "real" then "Sign in to build a mountain for this race"
    when "pretend" then "You don't live in #{@race.office.jurisdiction.name}. Your mountain is counted with visitors, never with residents."
    when "mock" then mock_text
    when "historical" then historical_text
    end
  end

  def mock_text
    ([ "Invented candidates" ] + [ election.creator && "made by #{election.creator.first_name}" ].compact).join(" · ")
  end

  def historical_text
    method = @race.decided_by ? "decided by #{@race.decided_by.humanize(capitalize: false)}" : "decided"
    "This race is over. It was #{method}; you're replaying it with approval."
  end

  def mode_aside
    case mode
    when "ballot", "real" then countdown
    when "pretend" then link_to("Go to my ballot", ballot_path, class: "mode-strip-action")
    when "mock" then span(class: "mode-strip-note") { "Not a real race" }
    when "historical" then span(class: "mode-strip-note") { "Real result shown after you save" }
    end
  end

  def countdown
    return unless election.days_until.positive?

    span(class: "mode-strip-note") do
      "Election day · #{election.election_date.strftime("%a %b %-d")} · #{pluralize(election.days_until, "day")}"
    end
  end
end
