class Views::States::NewView < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    div(class: "scaffold state-new", id: dom_id(@state, :new)) do
      h1 { "New state" }
      
      Views::States::StateForm(state: @state)
      
      div do
        link_to "Back to states", 
                states_path,
                class: "secondary"
      end
    end
  end
end