class Views::Approaches::ShowView < Views::ApplicationView
  def initialize(approach:, notice: nil)
    @approach = approach
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold approach-show", id: dom_id(@approach, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing approach" }
      
      Views::Approaches::ApproachPartial(approach: @approach)
      
      div do
        link_to "Edit this approach", 
                edit_approach_path(@approach),
                class: "secondary"
        link_to "Back to approaches", 
                approaches_path,
                class: "secondary"
        button_to "Destroy this approach", 
                  @approach,
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