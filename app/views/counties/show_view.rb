class Views::Counties::ShowView < Views::ApplicationView
  def initialize(county:)
    @county = county
  end

  def view_template(&)
    div(class: "scaffold county-show", id: dom_id(@county, :show)) do
      h1 { "Showing county" }

      CountyPartial(county: @county)

      Ui::ResourceActions(resource: @county)
    end
  end
end
