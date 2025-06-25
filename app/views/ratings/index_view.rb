class Views::Ratings::IndexView < Views::ApplicationView
  def initialize(ratings:, pagy: nil, notice: nil)
    @ratings = ratings
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold ratings-index", id: "index_ratings") do
      render_notice if @notice.present?
      
      div do
        h1 { "Ratings" }
        link_to "New rating", 
                new_rating_path,
                class: "primary"
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

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end