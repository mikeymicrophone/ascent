class Views::Counties::IndexView < Views::ApplicationView
  def initialize(counties:, pagy: nil)
    @counties = counties
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold counties-index", id: "index_counties") do
      div do
        h1 { "Counties" }
        scaffold_new_resource_link "New county", new_county_path, record: County
      end

      div(id: "counties") do
        if @counties.any?
          @counties.each do |county|
            div(id: dom_id(county, :list_item)) do
              CountyPartial(county: county)

              Ui::ResourceActions(resource: county)
            end
          end
        else
          p { "No counties found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
