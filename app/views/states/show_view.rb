class Views::States::ShowView < Views::ApplicationView
  def initialize(state:, notice: nil)
    @state = state
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold state-show", id: dom_id(@state, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing state" }
      
      StatePartial(state: @state)
      
      div do
        link_to "Edit this state", 
                edit_state_path(@state),
                class: "secondary"
        link_to "Back to states", 
                states_path,
                class: "secondary"
        button_to "Destroy this state", 
                  @state,
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