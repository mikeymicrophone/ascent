class Views::Ratings::IndexView < Views::ApplicationView
  def initialize(ratings:, pagy: nil)
    @ratings = ratings
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold ratings-index", id: "index_ratings") do
      div do
        h1 { "Ratings" }
        scaffold_new_resource_link "New rating", new_rating_path, record: Rating
      end

      div(id: "ratings") do
        if @ratings.any?
          @ratings.each do |rating|
            div(id: dom_id(rating, :list_item)) do
              RatingPartial(rating: rating)

              Ui::ResourceActions(resource: rating)
            end
          end
        else
          p { "No ratings found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
