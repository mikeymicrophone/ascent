class Views::Partials::CountyPartial < Views::ApplicationView
  def initialize(county:)
    @county = county
  end

  def view_template(&)
    div(id: dom_id(@county), class: "county-partial") do
      h3 { @county.name }

      HierarchicalNavigation(current_object: @county)

      if @county.code.present?
        div do
          span { "Code:" }
          whitespace
          span { @county.code }
        end
      end

      expandable(@county, :municipalities) do |municipalities|
        ItemPreview(@county, :municipalities, 5) do |municipality|
          link_to municipality.name, municipality, class: "link municipality"
        end
      end

      expandable(@county, :offices) do |offices|
        ItemPreview(@county, :offices, 3) do |office|
          link_to office.name, office, class: "link office"
        end
      end
    end
  end
end
