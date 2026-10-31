# frozen_string_literal: true

# A baseline's page body, seen only by its voter or an admin: where they draw approval in one race, and
# the baselines it replaced.
class Views::Partials::VoterRaceBaselinePartial < Views::ApplicationView
  prop :voter_race_baseline, VoterRaceBaseline

  def view_template
    section(class: "place-section") do
      section_heading("The baseline")
      dl(class: "place-facts-list") do
        FactRow(label: "Voter") { link_to @voter_race_baseline.voter.full_name, @voter_race_baseline.voter, class: "text-link" }
        FactRow(label: "Race") { link_to @voter_race_baseline.race.name, @voter_race_baseline.race, class: "text-link" }
        FactRow(label: "Baseline", value_class: "glance-value") { @voter_race_baseline.baseline.to_s }
        if @voter_race_baseline.has_archives?
          FactRow(label: "Earlier") { @voter_race_baseline.baseline_history.map(&:baseline).to_sentence }
        end
      end
    end
  end
end
