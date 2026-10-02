class Views::Partials::PositionPartial < Views::ApplicationView
  def initialize(position:)
    @position = position
  end

  def view_template(&)
    div(id: dom_id(@position), class: "position-partial") do
      # Header with title and executive indicator
      div(class: "partial-header") do
        h3(class: "partial-title") { @position.title }
        div(class: "header-indicators") do
          if @position.branch.present?
            span(class: "status-indicator status-#{@position.branch}") { @position.branch.titleize }
          end
        end
      end
      
      # Main content with improved layout
      div(class: "partial-content") do
        # Description with proper typography
        div(class: "content-section") do
          div(class: "content-description") { simple_format(@position.description) }
        end
        
        # Term information
        div(class: "info-grid") do
          div(class: "info-item") do
            span(class: "info-label") { "Term Length" }
            span(class: "info-value") { "#{@position.term_length_years} years" }
          end
        end
      end
      
      expandable(@position, :offices) do |offices|
        div(class: "expandable-grid") do
          offices.each { OfficePartial(office: it) }
        end
      end
    end
  end
end