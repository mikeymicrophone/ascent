class Views::States::IndexView < Views::ApplicationView
  def initialize(states:, notice: nil)
    @states = states
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold states-index", id: "index_states") do
      render_notice if @notice.present?
      
      div do
        h1 { "States" }
        link_to "New state", 
                new_state_path,
                class: "primary"
      end

      div(id: "states") do
        if @states.any?
          @states.each do |state|
            div(id: dom_id(state, :list_item)) do
              Views::States::StatePartial(state: state)
              
              div do
                link_to "Show", state,
                        class: "secondary"
                link_to "Edit", edit_state_path(state),
                        class: "secondary"
                button_to "Destroy", state,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No states found." }
        end
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