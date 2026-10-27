class Views::Ratings::EditView < Views::ApplicationView
  prop :rating, Rating

  def view_template
    ResourceFormPage(record: @rating) { render Views::Ratings::RatingForm.new(@rating) }
  end
end
