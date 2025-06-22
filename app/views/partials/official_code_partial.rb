class Views::Partials::OfficialCodePartial < Views::ApplicationView
  def initialize(official_code:)
    @official_code = official_code
  end

  def view_template(&)
    div(id: dom_id(@official_code), class: "official_code-partial") do
      h3 { @official_code.policy.name }
      div do
        span { "Code number:" }
        whitespace
        span { @official_code.code_number }
      end
      div do
        span { "Title:" }
        whitespace
        span { @official_code.title }
      end
      div do
        span { "Full text:" }
        whitespace
        div(class: "mt-1") { simple_format(@official_code.full_text) }
      end
      div do
        span { "Summary:" }
        whitespace
        div(class: "mt-1") { simple_format(@official_code.summary) }
      end
      div do
        span { "Enforcement mechanism:" }
        whitespace
        div(class: "mt-1") { simple_format(@official_code.enforcement_mechanism) }
      end
      div do
        span { "Penalty structure:" }
        whitespace
        div(class: "mt-1") { simple_format(@official_code.penalty_structure) }
      end
      div do
        span { "Effective date:" }
        whitespace
        span { @official_code.effective_date }
      end
      div do
        span { "Status:" }
        whitespace
        span { @official_code.status }
      end
    end
  end
end
