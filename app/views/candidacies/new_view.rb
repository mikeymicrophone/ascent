class Views::Candidacies::NewView < Views::ApplicationView
  prop :candidacy, Candidacy

  def view_template
    ResourceFormPage(record: @candidacy) { render Views::Candidacies::CandidacyForm.new(@candidacy, enctype: "multipart/form-data") }
  end
end
