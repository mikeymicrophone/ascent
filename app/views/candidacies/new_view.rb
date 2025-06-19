class Views::Candidacies::NewView < Views::ApplicationView
  def initialize(candidacy:)
    @candidacy = candidacy
  end

  def view_template(&)
    div(class: "scaffold candidacy-new", id: dom_id(@candidacy, :new)) do
      h1 { "New candidacy" }
      
      Views::Candidacies::CandidacyForm(candidacy: @candidacy)
      
      div do
        link_to "Back to candidacies", 
                candidacies_path,
                class: "secondary"
      end
    end
  end
end