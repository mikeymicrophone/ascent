class Views::AreaOfConcerns::IndexView < Views::ApplicationView
  def initialize(area_of_concerns:, pagy: nil)
    @area_of_concerns = area_of_concerns
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold area_of_concerns-index", id: "index_area_of_concerns") do
      div do
        h1 { "Area of concerns" }
        scaffold_new_resource_link "New area of concern", new_area_of_concern_path, record: AreaOfConcern
      end

      div(id: "area_of_concerns") do
        if @area_of_concerns.any?
          @area_of_concerns.each do |area_of_concern|
            div(id: dom_id(area_of_concern, :list_item)) do
              render AreaOfConcernPartial.new(area_of_concern: area_of_concern)

              Ui::ResourceActions(resource: area_of_concern)
            end
          end
        else
          p { "No area of concerns found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
