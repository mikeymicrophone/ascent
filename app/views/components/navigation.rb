class Views::Components::Navigation < Views::ApplicationView
  def initialize(current_voter: nil)
    @current_voter = current_voter
    @sections = []
  end

  def view_template(&block)
    if block
      yield(NavigationBuilder.new(self))
    else
      render_default_navigation
    end
    
    nav(class: "main-navigation") do
      div(class: "nav-container") do
        div(class: "nav-brand") do
          link_to "Ascent", root_path, class: "brand-link"
        end
        
        div(class: "nav-links") do
          @sections.each do |section|
            render_nav_section(section)
          end
          
          Views::Components::DeviseLinks(current_voter: @current_voter)
        end
      end
    end
  end

  def add_section(title, &block)
    section = NavigationSection.new(title)
    yield(section) if block
    @sections << section
  end

  private

  def render_default_navigation
    add_section("Jurisdictions") do |section|
      section.link("Countries", countries_path)
      section.link("States", states_path)
      section.link("Cities", cities_path)
    end
    
    add_section("Governance") do |section|
      section.link("Positions", positions_path)
      section.link("Governance Types", governance_types_path)
      section.link("Areas of Concern", area_of_concerns_path)
      section.link("Governing Bodies", governing_bodies_path)
      section.link("Offices", offices_path)
      section.link("Policies", policies_path)
      section.link("Official Codes", official_codes_path)
    end
    
    add_section("Policy") do |section|
      section.link("Topics", topics_path)
      section.link("Issues", issues_path)
      section.link("Approaches", approaches_path)
      section.link("Stances", stances_path)
    end
    
    add_section("Elections") do |section|
      section.link("Years", years_path)
      section.link("Elections", elections_path)
      section.link("People", people_path)
      section.link("Candidacies", candidacies_path)
    end
    
    add_section("Voting") do |section|
      section.link("Voters", voters_path)
      section.link("Residences", residences_path)
      section.link("Ratings", ratings_path)
      section.link("Baselines", voter_election_baselines_path)
      section.link("Mountains", mountains_path)
    end
  end

  def render_nav_section(section)
    div(class: "nav-group", data: { controller: "dropdown" }) do
      div(class: "nav-group-header", data: { action: "click->dropdown#toggle" }) do
        span { section.title }
        span(class: "nav-group-arrow") { "▼" }
      end
      div(class: "nav-group-content", data: { dropdown_target: "menu" }) do
        section.links.each do |link_data|
          link_to link_data[:text], link_data[:path], class: nav_link_class(link_data[:path])
        end
      end
    end
  end

  def nav_link_class(path)
    base_classes = "nav-link"
    current_page?(path) ? "#{base_classes} active" : base_classes
  end

  class NavigationBuilder
    def initialize(navigation)
      @navigation = navigation
    end

    def section(title, &block)
      @navigation.add_section(title, &block)
    end
  end

  class NavigationSection
    attr_reader :title, :links

    def initialize(title)
      @title = title
      @links = []
    end

    def link(text, path)
      @links << { text: text, path: path }
    end
  end
end