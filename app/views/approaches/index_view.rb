class Views::Approaches::IndexView < Views::ApplicationView
  def initialize(approaches:, pagy: nil)
    @approaches = approaches
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold approaches-index", id: "index_approaches") do
      div do
        h1 { "Approaches" }
        scaffold_new_resource_link "New approach", new_approach_path, record: Approach
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
end
