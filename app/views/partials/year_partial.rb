class Views::Partials::YearPartial < Views::ApplicationView
  def initialize(year:)
    @year = year
  end

  def view_template(&)
    div(id: dom_id(@year), class: "year-partial") do
      h3 { @year.year }
      div do
        span { "Is even year:" }
        whitespace
        span { @year.is_even_year.to_s }
      end
      div do
        span { "Is presidential year:" }
        whitespace
        span { @year.is_presidential_year.to_s }
      end
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@year.description) }
      end

      expandable(@year, :elections) do |elections|
        elections.each { ElectionPartial(election: it) }
      end
    end
  end
end