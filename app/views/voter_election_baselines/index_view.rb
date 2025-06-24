class Views::VoterElectionBaselines::IndexView < Views::ApplicationView
  def initialize(voter_election_baselines:, pagy: nil, notice: nil)
    @voter_election_baselines = voter_election_baselines
    @pagy = pagy
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
              VoterElectionBaselinePartial(voter_election_baseline: voter_election_baseline)
              
              Ui::ResourceActions(resource: voter_election_baseline)
            end
          end
        else
          p { "No voter election baselines found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end