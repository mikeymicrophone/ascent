class Views::Stances::IndexView < Views::ApplicationView
  def initialize(stances:, pagy: nil, notice: nil)
    @stances = stances
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold stances-index", id: "index_stances") do
      render_notice if @notice.present?
      
      div do
        h1 { "Stances" }
        link_to "New stance", 
                new_stance_path,
                class: "primary"
      end

      div(id: "stances") do
        if @stances.any?
          @stances.each do |stance|
            div(id: dom_id(stance, :list_item)) do
              Views::Stances::StancePartial(stance: stance)
              
              div do
                link_to "Show", stance,
                        class: "secondary"
                link_to "Edit", edit_stance_path(stance),
                        class: "secondary"
                button_to "Destroy", stance,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No stances found." }
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