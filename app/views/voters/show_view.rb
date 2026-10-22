class Views::Voters::ShowView < Views::ApplicationView
  prop :voter, Voter

  def view_template
    ResourceShow(record: @voter) { VoterPartial(voter: @voter) }
  end
end
