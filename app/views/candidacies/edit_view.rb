class Views::Candidacies::EditView < Views::ApplicationView
  def initialize(candidacy:)
    @candidacy = candidacy
  end

  def view_template(&)
    div(class: "scaffold candidacy-edit", id: dom_id(@candidacy, :edit)) do
      h1 { "Editing candidacy" }
      
      Views::Candidacies::CandidacyForm(candidacy: @candidacy)
      
      div do
        link_to "Show this candidacy", 
                @candidacy,
                class: "secondary"
        link_to "Back to candidacies", 
                candidacies_path,
                class: "secondary"
      end
    end
  end
end