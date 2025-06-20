class Views::Ratings::NewView < Views::ApplicationView
  def initialize(rating:)
    @rating = rating
  end

  def view_template(&)
    div(class: "scaffold rating-new", id: dom_id(@rating, :new)) do
      h1 { "New rating" }
      
      Views::Ratings::RatingForm(rating: @rating)
      
      div do
        link_to "Back to ratings", 
                ratings_path,
                class: "secondary"
      end
    end
  end
end