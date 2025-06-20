# frozen_string_literal: true

class Views::Mountains::CandidateColumn < Views::Components::Base
  def initialize(candidacy:, rating_value:, has_rating:, is_approved:, position_y:)
    @candidacy = candidacy
    @rating_value = rating_value
    @has_rating = has_rating
    @is_approved = is_approved
    @position_y = position_y
  end

  def view_template
    div(class: "candidate-column") do
      div(class: "rating-area") do
        render Views::Mountains::RatingDot.new(
          rating_value: @rating_value,
          has_rating: @has_rating,
          is_approved: @is_approved,
          position_y: @position_y
        )
      end
      
      div(class: "candidate-info") do
        h4(class: "candidate-name") { @candidacy.person.name }
        
        if @has_rating
          p(class: "rating-value") { "Rating: #{@rating_value}" }
        else
          p(class: "no-rating") { "Not rated" }
        end
      end
    end
  end

end