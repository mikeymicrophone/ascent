# frozen_string_literal: true

class Views::Components::Stat < Views::ApplicationView
  def initialize(value:, label:, kind: nil)
    @value = value
    @label = label
    @kind = kind
  end

  def view_template
    span(class: [ "stat-item", @kind ]) do
      span(class: "stat-value") { @value }
      whitespace
      span(class: "stat-label") { @label }
    end
  end
end
