class Views::Approaches::IndexView < Views::ApplicationView
  def initialize(approaches:, pagy: nil, notice: nil)
    @approaches = approaches
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold approaches-index", id: "index_approaches") do
      render_notice if @notice.present?
      
      div do
        h1 { "Approaches" }
        link_to "New approach", 
                new_approach_path,
                class: "primary"
      end

      div(id: "approaches") do
        if @approaches.any?
          @approaches.each do |approach|
            div(id: dom_id(approach, :list_item)) do
              ApproachPartial(approach: approach)
              
              Ui::ResourceActions(resource: approach)
            end
          end
        else
          p { "No approaches found." }
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