class Views::Elections::ShowView < Views::ApplicationView
  prop :election, Election

  def view_template
    ResourceShow(record: @election) do
      ElectionPartial(election: @election)

      scaffold_new_resource_link "Add a race", new_race_path(election_id: @election.id), record: Race
    end
  end
end
