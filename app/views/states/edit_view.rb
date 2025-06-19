class Views::States::EditView < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    div(class: "scaffold state-edit", id: dom_id(@state, :edit)) do
      h1 { "Editing state" }
      
      Views::States::StateForm(state: @state)
      
      div do
        link_to "Show this state", 
                @state,
                class: "secondary"
        link_to "Back to states", 
                states_path,
                class: "secondary"
      end
    end
  end
end