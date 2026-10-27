class Views::Partials::DistrictPartial < Views::ApplicationView
  def initialize(district:)
    @district = district
  end

  def view_template(&)
    div(id: dom_id(@district), class: "district-partial") do
      h3 { @district.name }
      div do
        span { "Kind:" }
        whitespace
        span { @district.kind }
      end

      expandable(@district, :offices) do |offices|
        ItemPreview(@district, :offices, 3) do |office|
          link_to office.name, office, class: "link office"
        end
      end

      expandable(@district, :elections) do |elections|
        ItemPreview(@district, :elections, 3) do |election|
          link_to election.name, election, class: "link election"
        end
      end
    end
  end
end
