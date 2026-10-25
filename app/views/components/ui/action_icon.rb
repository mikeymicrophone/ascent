# frozen_string_literal: true

class Views::Components::Ui::ActionIcon < Views::Components::Base
  prop :kind, Symbol

  def view_template
    svg(class: "resource-action-icon", viewbox: "0 0 24 24", fill: "none",
      stroke: "currentColor", stroke_width: "1.7", stroke_linecap: "round", stroke_linejoin: "round",
      aria: { hidden: true }, focusable: "false") do |s|
      case @kind
      when :simulate
        s.path(d: "M4 5v14h16 M8 15v-4 M12 15V8 M16 15v-3")
        s.path(d: "m18 3 1 3 3 1-3 1-1 3-1-3-3-1 3-1Z")
      when :show
        s.path(d: "M13 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-7 M15 4h5v5 M20 4l-9 9 M8 16h5")
      end
    end
  end
end
