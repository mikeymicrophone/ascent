class Views::Years::NewView < Views::ApplicationView
  def initialize(year:)
    @year = year
  end

  def view_template(&)
    div(class: "scaffold year-new", id: dom_id(@year, :new)) do
      h1 { "New year" }
      
      Views::Years::YearForm(year: @year)
      
      div do
        link_to "Back to years", 
                years_path,
                class: "secondary"
      end
    end
  end
end