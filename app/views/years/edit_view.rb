class Views::Years::EditView < Views::ApplicationView
  def initialize(year:)
    @year = year
  end

  def view_template(&)
    div(class: "scaffold year-edit", id: dom_id(@year, :edit)) do
      h1 { "Editing year" }
      
      Views::Years::YearForm(year: @year)
      
      div do
        link_to "Show this year", 
                @year,
                class: "secondary"
        link_to "Back to years", 
                years_path,
                class: "secondary"
      end
    end
  end
end