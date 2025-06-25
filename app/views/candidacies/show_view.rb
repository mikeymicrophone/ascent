class Views::Candidacies::ShowView < Views::ApplicationView
  def initialize(candidacy:, notice: nil)
    @candidacy = candidacy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold candidacy-show", id: dom_id(@candidacy, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing candidacy" }
      
      CandidacyPartial(candidacy: @candidacy)
      
      Ui::ResourceActions(resource: @candidacy)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end