class Views::Candidacies::IndexView < Views::ApplicationView
  def initialize(candidacies:, pagy: nil)
    @candidacies = candidacies
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold candidacies-index", id: "index_candidacies") do
      div do
        h1 { "Candidacies" }
        scaffold_new_resource_link "New candidacy", new_candidacy_path, record: Candidacy
      end

      div(id: "candidacies") do
        if @candidacies.any?
          @candidacies.each do |candidacy|
            div(id: dom_id(candidacy, :list_item)) do
              CandidacyPartial(candidacy: candidacy)

              Ui::ResourceActions(resource: candidacy)
            end
          end
        else
          p { "No candidacies found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
