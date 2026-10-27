class Views::Voters::EditView < Views::ApplicationView
  prop :voter, Voter

  def view_template
    ResourceFormPage(record: @voter) { render Views::Voters::VoterForm.new(@voter) }
  end
end
