class Views::States::IndexView < Views::ApplicationView
  def initialize(states:, pagy: nil, notice: nil)
    @states = states
    @pagy = pagy
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
              StatePartial(state: state)
              
              Ui::ResourceActions(resource: state)
            end
          end
        else
          p { "No states found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end