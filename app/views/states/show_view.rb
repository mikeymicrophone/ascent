class Views::States::ShowView < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    div(class: "scaffold state-show", id: dom_id(@state, :show)) do
      h1 { "Showing state" }

      StatePartial(state: @state)

      Ui::ResourceActions(resource: @state)
    end
  end
end
