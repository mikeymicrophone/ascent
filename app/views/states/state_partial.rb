class Views::States::StatePartial < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    div(id: dom_id(@state), class: "state-partial") do
      h3 { @state.name }
      div do
        span { "Code:" }
        whitespace
        span { @state.code }
      end
      div do
        span { "Country:" }
        whitespace
        link_to @state.country.name, @state.country, class: "link country"
      end
    end
  end
end