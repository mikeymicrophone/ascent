class Views::Ratings::EditView < Views::ApplicationView
  def initialize(rating:)
    @rating = rating
  end

  def view_template(&)
    div(class: "scaffold rating-edit", id: dom_id(@rating, :edit)) do
      h1 { "Editing rating" }
      
      Views::Ratings::RatingForm(rating: @rating)
      
      div do
        link_to "Show this rating", 
                @rating,
                class: "secondary"
        link_to "Back to ratings", 
                ratings_path,
                class: "secondary"
      end
    end
  end
end