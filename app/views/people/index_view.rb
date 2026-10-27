# frozen_string_literal: true

# Everyone who has stood for office, by surname: search by name or narrow to a state, and each row names
# the person's latest race and how they appear on its ballot.
class Views::People::IndexView < Views::ApplicationView
  prop :people, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash
  prop :states, ActiveRecord::Relation

  def view_template
    IndexPage(title: "People", records: @people, pagy: @pagy, noun: "person", frame: "people-list", eyebrow: "Candidates",
      lede: "Everyone who has stood for an office on Ascent, by surname. Search for a name, or pick a state.",
      trail: [ [ "Elections", elections_path ] ], clear_path: people_path,
      actions: (method(:new_person_link) if allowed_to?(:new?, Person)), filters: method(:filter_form)) { person_row(it) }
  end

  private

  def new_person_link
    PillLink(label: "New person", path: new_person_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: people_path, label: "Filter people", placeholder: "Search by name", values: @filters, clear_path: people_path,
      selects: [ [ :state_id, "State", @states.map { [ it.name, it.id ] }, "All states" ] ])
  end

  def person_row(person)
    latest = person.candidacies.max_by { it.race.election.election_date }
    ListRow(record: person, title: person.full_name, meta: latest_meta(latest, person), detail: latest&.ballot_labels) do
      span(class: "row-badge row-badge-mock") { "Invented" } if person.fictional
    end
  end

  def latest_meta(latest, person)
    return "No candidacies yet" unless latest

    text = "#{latest.race.office.name} · #{latest.race.election.election_date.strftime("%b %-d, %Y")}"
    person.candidacies.size > 1 ? "#{text} · #{pluralize(person.candidacies.size - 1, "earlier race")}" : text
  end
end
