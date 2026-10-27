# frozen_string_literal: true

# Every county by name: search for one, or narrow to a state. Each row counts the towns within it.
class Views::Counties::IndexView < Views::ApplicationView
  prop :counties, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash
  prop :states, ActiveRecord::Relation
  prop :town_counts, Hash

  def view_template
    IndexPage(title: "Counties", records: @counties, pagy: @pagy, noun: "county", frame: "counties-list", eyebrow: "Places",
      lede: "Every county and county-level region. Search for yours, or pick a state.", trail: [ [ "States", states_path ] ],
      clear_path: counties_path, actions: (method(:new_county_link) if allowed_to?(:new?, County)), filters: method(:filter_form)) { county_row(it) }
  end

  private

  def new_county_link
    PillLink(label: "New county", path: new_county_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: counties_path, label: "Filter counties", placeholder: "County name", values: @filters, clear_path: counties_path,
      selects: [ [ :state_id, "State", @states.map { [ it.name, it.id ] }, "All states" ] ])
  end

  def county_row(county)
    towns = @town_counts.fetch(county.id, 0)
    ListRow(record: county, title: county.name,
      meta: "#{county.state.name} · #{pluralize(delimited(towns), "city and town", plural: "cities and towns")}")
  end
end
