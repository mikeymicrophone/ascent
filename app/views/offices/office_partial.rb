class Views::Offices::OfficePartial < Views::ApplicationView
  def initialize(office:)
    @office = office
  end

  def view_template(&)
    div(id: dom_id(@office), class: "office-partial") do
      h3 { @office.position.title }
      div do
        span { "Jurisdiction:" }
        whitespace
        link_to @office.jurisdiction.name, @office.jurisdiction, class: "link jurisdiction"
      end
      div do
        span { "Is active:" }
        whitespace
        span { @office.is_active }
      end
      div do
        span { "Notes:" }
        whitespace
        div(class: "mt-1") { simple_format(@office.notes) }
      end
    end
  end
end