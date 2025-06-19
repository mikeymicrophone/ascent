class Views::Candidacies::ShowView < Views::ApplicationView
  def initialize(candidacy:, notice: nil)
    @candidacy = candidacy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold candidacy-show", id: dom_id(@candidacy, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing candidacy" }
      
      Views::Candidacies::CandidacyPartial(candidacy: @candidacy)
      
      div do
        link_to "Edit this candidacy", 
                edit_candidacy_path(@candidacy),
                class: "secondary"
        link_to "Back to candidacies", 
                candidacies_path,
                class: "secondary"
        button_to "Destroy this candidacy", 
                  @candidacy,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end