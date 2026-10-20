class Views::Municipalities::ShowView < Views::ApplicationView
  def initialize(municipality:, notice: nil)
    @municipality = municipality
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold municipality-show", id: dom_id(@municipality, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing municipality" }
      
      MunicipalityPartial(municipality: @municipality)
      
      Ui::ResourceActions(resource: @municipality)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end