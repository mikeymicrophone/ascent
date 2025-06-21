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

  def rating_scale_points
    [500, 400, 300, 200, 100, 0].map do |value|
      { value: value, position: Views::Mountains.calculate_label_position(value) }
    end
  end
end