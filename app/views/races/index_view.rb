class Views::Races::IndexView < Views::ApplicationView
  prop :races, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @races, pagy: @pagy, extra_actions: method(:simulate_button)) { RacePartial(race: it) }
  end

  private

  def simulate_button(race)
    return unless can_simulate_mountains?

    button_to("Simulate Data", simulate_mountain_path(race),
      method: :post, class: "btn-secondary", form: { style: "display: inline;" })
  end
end
