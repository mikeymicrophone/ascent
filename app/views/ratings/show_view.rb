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
      
      Ui::ResourceActions(resource: @rating)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end