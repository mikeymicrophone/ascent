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
    render Views::Components::ItemPreview.new(
      items: @city.offices,
      limit: 3,
      container_class: "offices-preview",
      item_class: "office-preview-item",
      view_all_class: "offices-view-all",
      view_all_text: "View all #{@city.offices.count} offices",
      view_all_path: offices_path(jurisdiction_type: "City", jurisdiction_id: @city.id)
    ) do |office|
      link_to office.name, office, class: "link office"
      span(class: "office-position") { " (#{office.position.title})" }
    end
  end

  def render_elections_preview(elections)
    render Views::Components::ItemPreview.new(
      items: elections,
      limit: 3,
      container_class: "elections-preview",
      item_class: "election-preview-item",
      view_all_class: "elections-view-all",
      view_all_text: "View all #{elections.count} elections",
      view_all_path: elections_path(jurisdiction_type: "City", jurisdiction_id: @city.id)
    ) do |election|
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
