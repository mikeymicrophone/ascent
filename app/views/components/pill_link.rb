# frozen_string_literal: true

# A rounded button-style link, optionally with an icon before its label.
#   PillLink(label: "Results", path: race_results_path(race), icon: :chart_column, variant: "outline")
class Views::Components::PillLink < Views::ApplicationView
  prop :label, String
  prop :path, String
  prop :icon, _Nilable(Symbol)
  prop :variant, _Nilable(String)

  def view_template
    link_to @path, class: [ "pill-button", ("pill-button-#{@variant}" if @variant) ].compact.join(" ") do
      icon(@icon) if @icon
      plain @label
    end
  end
end
