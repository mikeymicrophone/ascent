class Views::Voters::IndexView < Views::ApplicationView
  def initialize(voters:, pagy: nil)
    @voters = voters
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold voters-index", id: "index_voters") do
      div do
        h1 { "Voters" }
        scaffold_new_resource_link "New voter", new_voter_path, record: Voter
      end

      div(id: "voters") do
        if @voters.any?
          @voters.each do |voter|
            div(id: dom_id(voter, :list_item)) do
              VoterPartial(voter: voter)

              Ui::ResourceActions(resource: voter)
            end
          end
        else
          p { "No voters found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
