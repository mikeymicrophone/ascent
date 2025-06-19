class Views::Elections::ElectionPartial < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    div(id: dom_id(@election), class: "election-partial") do
      h3 { @election.office.name }
      div do
        span { "Year:" }
        whitespace
        link_to @election.year.name, @election.year, class: "link year"
      end
      div do
        span { "Election date:" }
        whitespace
        span { @election.election_date.strftime("%B %d, %Y") }
      end
      div do
        span { "Status:" }
        whitespace
        span { @election.status }
      end
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@election.description) }
      end
      div do
        span { "Is mock:" }
        whitespace
        span { @election.is_mock.to_s }
      end
      div do
        span { "Is historical:" }
        whitespace
        span { @election.is_historical.to_s }
      end
    end
  end
end