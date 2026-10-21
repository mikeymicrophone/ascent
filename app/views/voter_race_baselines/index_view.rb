class Views::VoterRaceBaselines::IndexView < Views::ApplicationView
  def initialize(voter_race_baselines:, pagy: nil)
    @voter_race_baselines = voter_race_baselines
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold voter_race_baselines-index", id: "index_voter_race_baselines") do
      div do
        h1 { "Voter race baselines" }
        scaffold_new_resource_link "New voter race baseline", new_voter_race_baseline_path, record: VoterRaceBaseline
      end

      div(id: "voter_race_baselines") do
        if @voter_race_baselines.any?
          @voter_race_baselines.each do |voter_race_baseline|
            div(id: dom_id(voter_race_baseline, :list_item)) do
              VoterRaceBaselinePartial(voter_race_baseline: voter_race_baseline)

              Ui::ResourceActions(resource: voter_race_baseline)
            end
          end
        else
          p { "No voter race baselines found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
