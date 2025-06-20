# frozen_string_literal: true

class Views::Mountains::YAxisLabels < Views::Components::Base
  def view_template
    div(class: "y-axis-labels") do
      rating_scale_points.each do |point|
        div(
          class: "axis-label",
          style: "top: #{point[:position]}px;"
        ) do
          span { point[:value] }
        end
      end
    end
  end

  private

  def rating_scale_points
    max_height = 320
    
    [500, 400, 300, 200, 100, 0].map do |value|
      position = max_height - (value.to_f / 500.0 * max_height)
      { value: value, position: position.to_i }
    end
  end
end