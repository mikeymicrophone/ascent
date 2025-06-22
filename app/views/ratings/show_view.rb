class Views::Ratings::ShowView < Views::ApplicationView
  def initialize(rating:, notice: nil)
    @rating = rating
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold rating-show", id: dom_id(@rating, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing rating" }
      
      RatingPartial(rating: @rating)
      
      div do
        link_to "Edit this rating", 
                edit_rating_path(@rating),
                class: "secondary"
        link_to "Back to ratings", 
                ratings_path,
                class: "secondary"
        button_to "Destroy this rating", 
                  @rating,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
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