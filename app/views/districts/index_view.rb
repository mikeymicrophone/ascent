# frozen_string_literal: true

# Every district, in number order: search by name, or narrow to a state and a kind of district, such as
# a state's congressional districts.
class Views::Districts::IndexView < Views::ApplicationView
  prop :districts, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash
  prop :states, ActiveRecord::Relation
  prop :kinds, Array

  def view_template
    IndexPage(title: "Districts", records: @districts, pagy: @pagy, noun: "district", frame: "districts-list", eyebrow: "Places",
      lede: "Legislative, judicial and local districts. Pick a state and a kind to find yours.", trail: [ [ "States", states_path ] ],
      clear_path: districts_path, actions: (method(:new_district_link) if allowed_to?(:new?, District)), filters: method(:filter_form)) { district_row(it) }
  end

  private

  def new_district_link
    PillLink(label: "New district", path: new_district_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: districts_path, label: "Filter districts", placeholder: "District name", values: @filters, clear_path: districts_path,
      selects: [
        [ :state_id, "State", @states.map { [ it.name, it.id ] }, "All states" ],
        [ :kind, "Kind of district", @kinds.map { [ it.capitalize, it ] }, "Every kind" ]
      ])
  end

  def district_row(district)
    container = district.jurisdiction&.parent&.jurisdictionable
    ListRow(record: district, title: district.name, meta: [ district.kind.capitalize, container&.name ].compact.join(" · "))
  end
end
