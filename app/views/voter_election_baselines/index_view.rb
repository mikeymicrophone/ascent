class Views::VoterElectionBaselines::IndexView < Views::ApplicationView
  def initialize(voter_election_baselines:, notice: nil)
    @voter_election_baselines = voter_election_baselines
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold voter_election_baselines-index", id: "index_voter_election_baselines") do
      render_notice if @notice.present?
      
      div do
        h1 { "Voter election baselines" }
        link_to "New voter election baseline", 
                new_voter_election_baseline_path,
                class: "primary"
      end

      div(id: "voter_election_baselines") do
        if @voter_election_baselines.any?
          @voter_election_baselines.each do |voter_election_baseline|
            div(id: dom_id(voter_election_baseline, :list_item)) do
              Views::VoterElectionBaselines::VoterElectionBaselinePartial(voter_election_baseline: voter_election_baseline)
              
              div do
                link_to "Show", voter_election_baseline,
                        class: "secondary"
                link_to "Edit", edit_voter_election_baseline_path(voter_election_baseline),
                        class: "secondary"
                button_to "Destroy", voter_election_baseline,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No voter election baselines found." }
        end
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end