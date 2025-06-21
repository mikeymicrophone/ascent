class Views::Cities::CityPartial < Views::ApplicationView
  def initialize(city:)
    @city = city
  end

  def view_template(&)
    div(id: dom_id(@city), class: "city-partial") do
      h3 { @city.name }
      
      # Hierarchical navigation
      Views::Components::HierarchicalNavigation(current_object: @city)
      
      # Offices expandable section
      if @city.offices.any?
        render_expandable_offices
      end
      
      # Active Elections expandable section
      active_elections = @city.offices.joins(:elections).includes(:elections).flat_map(&:elections).select { |e| e.status == 'active' }
      if active_elections.any?
        render_expandable_elections(active_elections)
      end
    end
  end

  private

  def render_expandable_offices
    Views::Components::ExpandableSection(
      title: "Offices",
      count: @city.offices.count
    ) do
      Views::Components::ItemPreview(@city, :offices, 3) do |office|
        link_to office.name, office, class: "link office"
        span(class: "office-position") { " (#{office.position.title})" }
      end
    end
  end

  def render_expandable_elections(elections)
    Views::Components::ExpandableSection(
      title: "Active Elections",
      count: elections.count
    ) do
      Views::Components::ItemPreview(@city, :active_elections, 3) do |election|
        link_to election.name, election, class: "link election"
        div(class: "election-status") do
          span(class: "status-indicator status-#{election.status}") { election.status.capitalize }
          if election.election_date
            span(class: "election-date") { " - #{election.election_date.strftime("%B %d, %Y")}" }
          end
        end
      end
    end
  end
end
