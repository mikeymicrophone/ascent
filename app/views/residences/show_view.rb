class Views::Residences::ShowView < Views::ApplicationView
  def initialize(residence:, notice: nil)
    @residence = residence
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold residence-show", id: dom_id(@residence, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing residence" }
      
      render Views::Residences::ResidencePartial.new(residence: @residence)
      
      div do
        link_to "Edit this residence", 
                edit_residence_path(@residence),
                class: "secondary"
        link_to "Back to residences", 
                residences_path,
                class: "secondary"
        button_to "Destroy this residence", 
                  @residence,
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