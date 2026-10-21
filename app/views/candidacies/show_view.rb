class Views::Candidacies::ShowView < Views::ApplicationView
  def initialize(candidacy:)
    @candidacy = candidacy
  end

  def view_template(&)
    div(class: "scaffold candidacy-show", id: dom_id(@candidacy, :show)) do
      h1 { "Showing candidacy" }

      CandidacyPartial(candidacy: @candidacy)

      Ui::ResourceActions(resource: @candidacy)
    end
  end
end
