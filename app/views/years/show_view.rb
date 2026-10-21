class Views::Years::ShowView < Views::ApplicationView
  def initialize(year:)
    @year = year
  end

  def view_template(&)
    div(class: "scaffold year-show", id: dom_id(@year, :show)) do
      h1 { "Showing year" }

      YearPartial(year: @year)

      Ui::ResourceActions(resource: @year)
    end
  end
end
