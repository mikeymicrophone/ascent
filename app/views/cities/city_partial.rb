class Views::Cities::CityPartial < Views::ApplicationView
  def initialize(city:)
    @city = city
  end

  def view_template(&)
    div(id: dom_id(@city), class: "city-partial") do
      h3 { @city.name }
      div do
        span { "State:" }
        whitespace
        link_to @city.state.name, @city.state, class: "link state"
      end
      
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
    render Views::Components::ExpandableSection.new(
      title: "Offices",
      count: @city.offices.count
    ) do
      render_offices_preview
    end
  end

  def render_expandable_elections(elections)
    render Views::Components::ExpandableSection.new(
      title: "Active Elections",
      count: elections.count
    ) do
      render_elections_preview(elections)
    end
  end

  def render_offices_preview
    div(class: "offices-preview") do
      # Show first 3 offices
      @city.offices.limit(3).each do |office|
        div(class: "office-preview-item") do
          link_to office.name, office, class: "link office"
          span(class: "office-position") { " (#{office.position.title})" }
        end
      end
      
      # Show "View All" link if there are more than 3 offices
      if @city.offices.count > 3
        div(class: "offices-view-all") do
          link_to "View all #{@city.offices.count} offices", 
                  offices_path(jurisdiction_type: "City", jurisdiction_id: @city.id), 
                  class: "link view-all"
        end
      end
    end
  end

  def render_elections_preview(elections)
    div(class: "elections-preview") do
      # Show first 3 elections
      elections.first(3).each do |election|
        div(class: "election-preview-item") do
          link_to election.name, election, class: "link election"
          div(class: "election-status") do
            span(class: "status-indicator status-#{election.status}") { election.status.capitalize }
            if election.election_date
              span(class: "election-date") { " - #{election.election_date.strftime("%B %d, %Y")}" }
            end
          end
        end
      end
      
      # Show "View All" link if there are more than 3 elections  
      if elections.count > 3
        div(class: "elections-view-all") do
          link_to "View all #{elections.count} elections", 
                  elections_path(jurisdiction_type: "City", jurisdiction_id: @city.id), 
                  class: "link view-all"
        end
      end
    end
  end
end
