class Views::Races::IndexView < Views::ApplicationView
  prop :races, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash
  prop :scope, Hash
  prop :states, ActiveRecord::Relation
  prop :years, Array
  prop :kinds, Array

  def view_template
    ResourceIndex(collection: @races, pagy: @pagy, filters: method(:filter_form),
      extra_actions: method(:simulate_button)) { RacePartial(race: it) }
  end

  private

  def filter_form
    form_with url: races_path, method: :get, class: "race-filters", local: true, aria: { label: "Filter races" } do |form|
      @scope.each { |key, value| form.hidden_field key, value: value }

      div(class: "race-filter-search") do
        form.label :q, "Search races"
        form.search_field :q, value: @filters["q"], placeholder: "Office, election, or candidate"
      end
      div do
        form.label :state_id, "State"
        form.select :state_id, @states.map { [ it.name, it.id ] }, include_blank: "All states", selected: @filters["state_id"]
      end
      div do
        form.label :year, "Election year"
        form.select :year, @years, include_blank: "All years", selected: @filters["year"]
      end
      div do
        form.label :status, "Race status"
        form.select :status, Race::STATUSES.map { [ it.capitalize, it ] }, include_blank: "All statuses", selected: @filters["status"]
      end
      div do
        form.label :kind, "Election kind"
        form.select :kind, @kinds.map { [ it.humanize, it ] }, include_blank: "All kinds", selected: @filters["kind"]
      end
      div(class: "race-filter-actions") do
        button(type: "submit", class: "resource-action resource-action-simulate") do
          icon(:funnel)
          plain "Apply filters"
        end
        link_to "Clear", races_path(@scope), class: "resource-action resource-action-show"
        p(class: "race-filter-summary", role: "status") { pluralize(@pagy.count, "race") }
      end
    end
  end

  def simulate_button(race)
    return unless can_simulate_mountains? && race.mock?

    button_to simulate_mountain_path(race), method: :post,
      class: "resource-action resource-action-simulate", form_class: "resource-action-form" do
      Ui::ActionIcon(kind: :simulate)
      span { "Simulate Data" }
    end
  end
end
