class Views::AreaOfConcerns::ShowView < Views::ApplicationView
  def initialize(area_of_concern:, notice: nil)
    @area_of_concern = area_of_concern
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold area_of_concern-show", id: dom_id(@area_of_concern, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing area of concern" }
      
      render AreaOfConcernPartial.new(area_of_concern: @area_of_concern)
      
      div do
        link_to "Edit this area of concern", 
                edit_area_of_concern_path(@area_of_concern),
                class: "secondary"
        link_to "Back to area of concerns", 
                area_of_concerns_path,
                class: "secondary"
        button_to "Destroy this area of concern", 
                  @area_of_concern,
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