class Views::Ratings::RatingPartial < Views::ApplicationView
  def initialize(rating:)
    @rating = rating
  end

  def view_template(&)
    div(id: dom_id(@rating), class: "rating-partial") do
      h3 { @rating.voter_id }
      div do
        span { "Candidacy:" }
        whitespace
        link_to @rating.candidacy.name, @rating.candidacy, class: "link candidacy"
      end
      div do
        span { "Rating:" }
        whitespace
        span { @rating.rating }
      end
    end
  end
end