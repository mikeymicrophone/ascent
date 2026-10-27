class Views::Candidacies::EditView < Views::ApplicationView
  prop :candidacy, Candidacy

  def view_template
    ResourceFormPage(record: @candidacy) { render Views::Candidacies::CandidacyForm.new(@candidacy) }
  end
end
