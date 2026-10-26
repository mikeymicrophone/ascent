# frozen_string_literal: true

# A card in a page's side column: a small heading over whatever the block draws.
#   SideCard(heading: "Where it is") { ... }
class Views::Components::SideCard < Views::ApplicationView
  prop :heading, String
  prop :modifier, _Nilable(String)
  prop :id, _Nilable(String)

  def view_template(&)
    section(class: [ "side-card", @modifier ].compact.join(" "), id: @id) do
      h2(class: "card-heading") { @heading }
      yield
    end
  end
end
