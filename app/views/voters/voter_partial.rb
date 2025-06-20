class Views::Voters::VoterPartial < Views::ApplicationView
  def initialize(voter:)
    @voter = voter
  end

  def view_template(&)
    div(id: dom_id(@voter), class: "voter-partial") do
      h3 { @voter.first_name }
      div do
        span { "Last name:" }
        whitespace
        span { @voter.last_name }
      end
      div do
        span { "Birth date:" }
        whitespace
        span { @voter.birth_date.strftime("%B %d, %Y") }
      end
      div do
        span { "Is verified:" }
        whitespace
        span { @voter.is_verified.to_s }
      end
    end
  end
end