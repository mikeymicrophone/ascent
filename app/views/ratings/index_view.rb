class Views::Ratings::IndexView < Views::ApplicationView
  prop :ratings, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @ratings, pagy: @pagy) { RatingPartial(rating: it) }
  end
end
