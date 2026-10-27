class Views::Partials::VoterRaceBaselinePartial < Views::ApplicationView
  def initialize(voter_race_baseline:)
    @voter_race_baseline = voter_race_baseline
  end

  def view_template(&)
    div(id: dom_id(@voter_race_baseline), class: "voter_race_baseline-partial") do
      h3 { "#{@voter_race_baseline.voter.name} had baseline of" }
      div do
        span { @voter_race_baseline.baseline }
        span { " on " }
        whitespace
        link_to @voter_race_baseline.race.name, @voter_race_baseline.race, class: "link race"

        if @voter_race_baseline.has_archives?
          span { " (After establishing prior baselines of: " }
          @voter_race_baseline.baseline_history.map { it.baseline }.to_sentence
          span { ")" }
        end
      end
    end
  end
end
