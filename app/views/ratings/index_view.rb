class Views::Ratings::IndexView < Views::ApplicationView
  def initialize(ratings:, notice: nil)
    @ratings = ratings
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
              Views::Ratings::RatingPartial(rating: rating)
              
              div do
                link_to "Show", rating,
                        class: "secondary"
                link_to "Edit", edit_rating_path(rating),
                        class: "secondary"
                button_to "Destroy", rating,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No ratings found." }
        end
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end