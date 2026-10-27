# frozen_string_literal: true

# Every state, or a country's states, by name: each row counts the counties and towns within it.
class Views::States::IndexView < Views::ApplicationView
  prop :states, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(Country)
  prop :filters, Hash
  prop :county_counts, Hash
  prop :town_counts, Hash

  def view_template
    IndexPage(title: @parent ? "States in #{@parent.name}" : "States", records: @states, pagy: @pagy, noun: "state", frame: "states-list",
      eyebrow: "Places", lede: "Pick a state to see its statewide races, then find your county or town within it.",
      trail: @parent ? [ [ "Countries", countries_path ], [ @parent.name, @parent ] ] : [ [ "Countries", countries_path ] ],
      clear_path: list_path, actions: (method(:new_state_link) if allowed_to?(:new?, ::State)), filters: method(:filter_form)) { state_row(it) }
  end

  private

  def list_path
    @parent ? country_states_path(@parent) : states_path
  end

  def new_state_link
    PillLink(label: "New state", path: new_state_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: list_path, label: "Filter states", placeholder: "State name", values: @filters, clear_path: list_path)
  end

  def state_row(state)
    counties = @county_counts.fetch(state.id, 0)
    towns = @town_counts.fetch(state.id, 0)
    ListRow(record: state, title: state.name, meta: "#{state.country.name} · #{pluralize(delimited(counties), "county", plural: "counties")} · " \
      "#{pluralize(delimited(towns), "city and town", plural: "cities and towns")}") do
      span(class: "row-badge") { state.code } if state.code.present?
    end
  end
end
