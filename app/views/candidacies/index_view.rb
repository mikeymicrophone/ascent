class Views::Candidacies::IndexView < Views::ApplicationView
  def initialize(candidacies:, pagy: nil, notice: nil)
    @candidacies = candidacies
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold candidacies-index", id: "index_candidacies") do
      render_notice if @notice.present?
      
      div do
        h1 { "Candidacies" }
        link_to "New candidacy", 
                new_candidacy_path,
                class: "primary"
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

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end