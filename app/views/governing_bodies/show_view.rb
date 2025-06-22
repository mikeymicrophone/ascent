class Views::GoverningBodies::ShowView < Views::ApplicationView
  def initialize(governing_body:, notice: nil)
    @governing_body = governing_body
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold governing_body-show", id: dom_id(@governing_body, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing governing body" }
      
      render GoverningBodyPartial.new(governing_body: @governing_body)
      
      div do
        link_to "Edit this governing body", 
                edit_governing_body_path(@governing_body),
                class: "secondary"
        link_to "Back to governing bodies", 
                governing_bodies_path,
                class: "secondary"
        button_to "Destroy this governing body", 
                  @governing_body,
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