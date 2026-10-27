# frozen_string_literal: true

# Every city and town by name: search for one, or narrow to a state or a county, as the state and county
# pages do when they send a visitor here.
class Views::Municipalities::IndexView < Views::ApplicationView
  prop :municipalities, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash
  prop :states, ActiveRecord::Relation
  prop :county, _Nilable(County)

  def view_template
    IndexPage(title: title, records: @municipalities, pagy: @pagy, noun: "municipality", frame: "municipalities-list", eyebrow: "Places",
      lede: "Find your city or town to see what is on its ballot.", trail: trail, clear_path: municipalities_path(@filters.slice("county_id")),
      actions: (method(:new_municipality_link) if scaffold_new_resource_visible?(Municipality)), filters: method(:filter_form)) { town_row(it) }
  end

  private

  def title
    @county ? "Cities and towns in #{@county.name}" : "Municipalities"
  end

  def trail
    @county ? [ [ @county.state.name, @county.state ], [ @county.name, @county ] ] : [ [ "States", states_path ] ]
  end

  def new_municipality_link
    PillLink(label: "New municipality", path: new_municipality_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: municipalities_path, label: "Filter cities and towns", placeholder: "City or town name", values: @filters,
      clear_path: municipalities_path(@filters.slice("county_id")), hidden: @filters.slice("county_id"),
      selects: (@county ? [] : [ [ :state_id, "State", @states.map { [ it.name, it.id ] }, "All states" ] ]))
  end

  def town_row(municipality)
    ListRow(record: municipality, title: municipality.name,
      meta: [ municipality.distinct_county&.name, municipality.state.name, municipality.state.country&.name ].compact.join(", "))
  end
end
