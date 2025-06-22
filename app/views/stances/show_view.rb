class Views::Stances::ShowView < Views::ApplicationView
  def initialize(stance:, notice: nil)
    @stance = stance
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold stance-show", id: dom_id(@stance, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing stance" }
      
      Views::Stances::StancePartial(stance: @stance)
      
      div do
        link_to "Edit this stance", 
                edit_stance_path(@stance),
                class: "secondary"
        link_to "Back to stances", 
                stances_path,
                class: "secondary"
        button_to "Destroy this stance", 
                  @stance,
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