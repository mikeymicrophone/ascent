# frozen_string_literal: true

class Views::Mountains::CandidateColumn < Views::Components::Base
  def initialize(candidacy:, rating_value:, has_rating:, is_approved:, position_y:, editable: false, rating_input_id: nil)
    @candidacy = candidacy
    @rating_value = rating_value
    @has_rating = has_rating
    @is_approved = is_approved
    @position_y = position_y
    @editable = editable
    @rating_input_id = rating_input_id
  end

  def view_template
    div(class: "candidate-column", data: column_data) do
      div(class: "rating-area", data: rating_area_data) do
        render Views::Mountains::RatingDot.new(
          rating_value: @rating_value,
          has_rating: @has_rating,
          is_approved: @is_approved,
          position_y: @position_y
        )
      end
      
      div(class: "candidate-info") do
        h4(class: "candidate-name") do
          link_to @candidacy.person.name, @candidacy, class: "candidate-link"
        end
        
        p(
          class: "rating-value",
          data: { role: "rating-value" },
          hidden: !@has_rating
        ) { "Rating: #{@rating_value}" }
        p(
          class: "no-rating",
          data: { role: "no-rating" },
          hidden: @has_rating
        ) { "Not rated" }
        
        if @candidacy.stances.any?
          p(class: "stance-count") do
            link_to "#{@candidacy.stances.count} policy positions", @candidacy, class: "stance-link"
          end
        end
      end
    end
  end

  def column_data
    return {} unless @editable

    {
      candidacy_id: @candidacy.id,
      rating_input_id: @rating_input_id
    }
  end

  def rating_area_data
    return {} unless @editable

    {
      role: "rating-area",
      action: "pointerdown->mountain-editor#startRatingDrag pointermove->mountain-editor#dragRating pointerup->mountain-editor#stopRatingDrag pointercancel->mountain-editor#stopRatingDrag"
    }
  end

end
