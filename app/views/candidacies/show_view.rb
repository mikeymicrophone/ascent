class Views::Candidacies::ShowView < Views::ApplicationView
  prop :candidacy, Candidacy

  def view_template
    ResourceShow(record: @candidacy) { CandidacyPartial(candidacy: @candidacy) }
  end
end
