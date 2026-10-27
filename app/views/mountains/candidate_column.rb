# frozen_string_literal: true

# One candidate's column: their rating drawn as a peak, its summit lime where it rises above the
# baseline, with the rope crossing it. The mountain-range controller redraws the same shapes as they move.
class Views::Mountains::CandidateColumn < Views::Components::Base
  # Half the width of a peak's base, in columns: each peak spreads 70% of a column either side.
  PEAK_SPREAD = 70

  def initialize(candidacy:, rating_value:, has_rating:, is_approved:, baseline: nil, editable: false, rating_input_id: nil)
    @candidacy = candidacy
    @rating_value = rating_value
    @has_rating = has_rating
    @is_approved = is_approved
    @baseline = baseline
    @editable = editable
    @rating_input_id = rating_input_id
  end

  def view_template
    div(class: column_classes, data: column_data) do
      div(class: "rating-area", data: rating_area_data) do
        peak
        render Views::Mountains::RatingDot.new(
          rating_value: @rating_value,
          has_rating: @has_rating,
          is_approved: @is_approved
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

  def peak
    svg(class: "mountain-peak", viewbox: "-#{PEAK_SPREAD} 0 #{PEAK_SPREAD * 2} 500", preserveaspectratio: "none", aria: { hidden: true }) do |s|
      s.path(class: "peak-body", d: peak_path, data: { role: "peak-body" })
      s.path(class: "peak-summit", d: summit_path, data: { role: "peak-summit" })
      s.path(class: "peak-rope", d: rope_path, data: { role: "peak-rope" })
    end
  end

  def peak_path
    return "" unless @has_rating && @rating_value.positive?

    "M -#{PEAK_SPREAD} 500 L 0 #{500 - @rating_value} L #{PEAK_SPREAD} 500 Z"
  end

  def summit_path
    return "" unless summit?

    "M -#{summit_spread} #{500 - @baseline} L 0 #{500 - @rating_value} L #{summit_spread} #{500 - @baseline} Z"
  end

  def rope_path
    return "" unless summit?

    "M -#{summit_spread} #{500 - @baseline} H #{summit_spread}"
  end

  def summit?
    @has_rating && @baseline && @rating_value > @baseline
  end

  # How wide the peak is where the baseline crosses it.
  def summit_spread
    (PEAK_SPREAD * (1 - @baseline.to_f / @rating_value)).round(2)
  end

  def column_classes
    [ "candidate-column", ("off-ballot" if @candidacy.primary_candidacy_id.present?) ].compact.join(" ")
  end

  def column_data
    shared = { mountain_range_target: "column", rating: (@rating_value if @has_rating) }
    return shared unless @editable

    shared.merge(candidacy_id: @candidacy.id, rating_input_id: @rating_input_id)
  end

  def rating_area_data
    return {} unless @editable

    {
      role: "rating-area",
      action: "pointerdown->mountain-editor#startRatingDrag"
    }
  end
end
