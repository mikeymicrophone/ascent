# frozen_string_literal: true

# Every office, by position: search by title or place, narrow to a state, or hide offices no longer
# filled. Each row says where the office sits and when it is next decided.
class Views::Offices::IndexView < Views::ApplicationView
  prop :offices, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash
  prop :states, ActiveRecord::Relation

  def view_template
    IndexPage(title: "Offices", records: @offices, pagy: @pagy, noun: "office", frame: "offices-list", eyebrow: "Seats",
      lede: "Every seat Ascent knows of, from governor to school board. Search for a title or a place, or pick a state.",
      trail: [ [ "Elections", elections_path ] ], clear_path: offices_path,
      actions: (method(:new_office_link) if allowed_to?(:new?, Office)), filters: method(:filter_bar)) { office_row(it) }
  end

  private

  def new_office_link
    PillLink(label: "New office", path: new_office_path, icon: :plus)
  end

  def filter_bar
    active_chip
    FilterForm(url: offices_path, label: "Filter offices", placeholder: "Title or place", values: @filters, clear_path: offices_path,
      hidden: @filters.slice("active", "governing_body_id"), selects: [ [ :state_id, "State", @states.map { [ it.name, it.id ] }, "All states" ] ])
  end

  def active_chip
    active = @filters["active"] == "1"
    link_to offices_path(@filters.merge("active" => (active ? nil : "1")).compact_blank), class: "filter-chip#{" is-current" if active}",
      aria: { pressed: active.to_s } do
      icon(:circle_check)
      plain "Filled seats only"
    end
  end

  def office_row(office)
    next_race = office.races.select { ahead?(it) }.min_by { it.election.election_date }
    ListRow(record: office, title: office.name, meta: office_meta(next_race)) do
      span(class: "row-badge") { "Inactive" } unless office.is_active
      StatusChip(status: next_race.status) if next_race
    end
  end

  def office_meta(next_race)
    return "No race scheduled" unless next_race

    "Next race #{next_race.election.election_date.strftime("%b %-d, %Y")} · #{pluralize(next_race.candidacies.size, "candidate")}"
  end
end
