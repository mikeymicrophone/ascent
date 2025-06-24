class Views::Residences::ShowView < Views::ApplicationView
  def initialize(residence:, notice: nil)
    @residence = residence
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold residence-show", id: dom_id(@residence, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing residence" }
      
      render ResidencePartial.new(residence: @residence)
      
      Ui::ResourceActions(resource: @residence)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end