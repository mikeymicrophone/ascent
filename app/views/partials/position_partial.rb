class Views::Partials::PositionPartial < Views::ApplicationView
  def initialize(position:)
    @position = position
  end

  def view_template(&)
    div(id: dom_id(@position), class: "position-partial") do
      h3 { @position.title }
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@position.description) }
      end
      div do
        span { "Is executive:" }
        whitespace
        span { @position.is_executive }
      end
      div do
        span { "Term length years:" }
        whitespace
        span { @position.term_length_years }
      end
      
      expandable(@position, :offices) do |offices|
        offices.each { OfficePartial(office: it) }
      end
    end
  end
end