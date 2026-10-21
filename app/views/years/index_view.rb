class Views::Years::IndexView < Views::ApplicationView
  def initialize(years:, pagy: nil)
    @years = years
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold years-index", id: "index_years") do
      div do
        h1 { "Years" }
        scaffold_new_resource_link "New year", new_year_path, record: Year
      end

      div(id: "years") do
        if @years.any?
          @years.each do |year|
            div(id: dom_id(year, :list_item)) do
              YearPartial(year: year)

              Ui::ResourceActions(resource: year)
            end
          end
        else
          p { "No years found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
