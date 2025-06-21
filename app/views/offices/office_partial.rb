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
        span { @office.is_active.to_s }
      end
      div do
        span { "Notes:" }
        whitespace
        div(class: "mt-1") { simple_format(@office.notes) }
      end
      
      render_election_history
    end
  end

  private

  def render_election_history
    return unless @office.elections.any?
    
    Views::Components::ExpandableSection(
      title: "Election History",
      count: @office.elections.count
    ) do
      Views::Components::ItemPreview(@office, :elections, 3) do |election|
        link_to election.name, election, class: "link election"
      end
    end
  end
end