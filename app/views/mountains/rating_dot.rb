# frozen_string_literal: true

class Views::Mountains::RatingDot < Views::Components::Base
  def initialize(rating_value:, has_rating:, is_approved:, position_y:)
    @rating_value = rating_value
    @has_rating = has_rating
    @is_approved = is_approved
    @position_y = position_y
  end

  def view_template
    div(
      class: rating_dot_classes,
      style: "top: #{@position_y}px;",
      title: rating_tooltip
    ) do
      # Dot content if needed
    end
  end

  private

  def rating_dot_classes
    classes = ["rating-dot"]
    
    if @has_rating
      classes << (@is_approved ? "approved" : "disapproved")
    else
      classes << "unrated"
    end
    
    classes.join(" ")
  end

  def rating_tooltip
    if @has_rating
      "Rating: #{@rating_value} (#{@is_approved ? 'Approved' : 'Disapproved'})"
    else
      "Not rated"
    end
  end
end