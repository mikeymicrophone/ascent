class Views::Ratings::ShowView < Views::ApplicationView
  def initialize(rating:)
    @rating = rating
  end

  def view_template(&)
    div(class: "scaffold rating-show", id: dom_id(@rating, :show)) do
      h1 { "Showing rating" }

      RatingPartial(rating: @rating)

      Ui::ResourceActions(resource: @rating)
    end
  end
end
