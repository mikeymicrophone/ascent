class Views::Elections::ShowView < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    div(class: "scaffold election-show", id: dom_id(@election, :show)) do
      h1 { "Showing election" }

      ElectionPartial(election: @election)

      scaffold_new_resource_link "Add a race", new_race_path(election_id: @election.id), record: Race

      Ui::ResourceActions(resource: @election)
    end
  end
end
