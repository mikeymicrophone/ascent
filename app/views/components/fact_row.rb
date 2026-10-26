# frozen_string_literal: true

# One labelled fact in a side card's list; the block draws the value, often a link.
#   dl(class: "place-facts-list") { FactRow(label: "State") { link_to state.name, state } }
class Views::Components::FactRow < Views::ApplicationView
  prop :label, String
  prop :value_class, _Nilable(String)

  def view_template(&)
    div(class: "place-fact-row") do
      dt { @label }
      dd(class: @value_class, &)
    end
  end
end
