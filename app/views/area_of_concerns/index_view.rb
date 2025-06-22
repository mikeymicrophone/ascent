class Views::AreaOfConcerns::IndexView < Views::ApplicationView
  def initialize(area_of_concerns:, pagy: nil, notice: nil)
    @area_of_concerns = area_of_concerns
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold area_of_concerns-index", id: "index_area_of_concerns") do
      render_notice if @notice.present?
      
      div do
        h1 { "Area of concerns" }
        link_to "New area of concern", 
                new_area_of_concern_path,
                class: "primary"
      end

      div(id: "area_of_concerns") do
        if @area_of_concerns.any?
          @area_of_concerns.each do |area_of_concern|
            div(id: dom_id(area_of_concern, :list_item)) do
              render AreaOfConcernPartial.new(area_of_concern: area_of_concern)
              
              div do
                link_to "Show", area_of_concern,
                        class: "secondary"
                link_to "Edit", edit_area_of_concern_path(area_of_concern),
                        class: "secondary"
                button_to "Destroy", area_of_concern,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No area of concerns found." }
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