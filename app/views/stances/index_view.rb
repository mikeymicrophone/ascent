# frozen_string_literal: true

# Every candidate's stance, by candidate: search by name or narrow by how much the stance matters to them.
class Views::Stances::IndexView < Views::ApplicationView
  PRIORITIES = %w[high medium low].freeze

  prop :stances, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash

  def view_template
    IndexPage(title: "Stances", records: @stances, pagy: @pagy, noun: "stance", frame: "stances-list", eyebrow: "Policy",
      lede: "Where candidates stand: each stance ties a candidate to an approach on an issue, with the evidence for it.",
      trail: [ [ "Topics", topics_path ] ], clear_path: stances_path, actions: (method(:new_stance_link) if allowed_to?(:new?, Stance)),
      filters: method(:filter_form)) { StanceRow(stance: it) }
  end

  private

  def new_stance_link
    PillLink(label: "New stance", path: new_stance_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: stances_path, label: "Filter stances", placeholder: "Candidate's name", values: @filters, clear_path: stances_path,
      selects: [ [ :priority_level, "Priority", PRIORITIES.map { [ "#{it.capitalize} priority", it ] }, "Any priority" ] ])
  end
end
