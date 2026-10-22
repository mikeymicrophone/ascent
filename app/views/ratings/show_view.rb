class Views::Ratings::ShowView < Views::ApplicationView
  prop :rating, Rating

  def view_template
    ResourceShow(record: @rating) { RatingPartial(rating: @rating) }
  end
end
