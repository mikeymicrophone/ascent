# frozen_string_literal: true

# Every approach, or an issue's approaches: each row counts the candidates who take it and the laws that
# put it in place.
class Views::Approaches::IndexView < Views::ApplicationView
  prop :approaches, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(Issue)
  prop :filters, Hash
  prop :stance_counts, Hash
  prop :policy_counts, Hash

  def view_template
    IndexPage(title: @parent ? "Ways to address #{@parent.title}" : "Approaches", records: @approaches, pagy: @pagy, noun: "approach",
      frame: "approaches-list", eyebrow: "Policy", lede: "Ways to address an issue, with the candidates who take each one and the laws that put it in place.",
      trail: trail, clear_path: list_path, actions: (method(:new_approach_link) if allowed_to?(:new?, Approach)),
      filters: method(:filter_form)) { approach_row(it) }
  end

  private

  def trail
    return [ [ "Topics", topics_path ] ] unless @parent

    [ [ "Topics", topics_path ], [ @parent.topic.title, @parent.topic ], [ @parent.title, @parent ] ]
  end

  def list_path
    @parent ? issue_approaches_path(@parent) : approaches_path
  end

  def new_approach_link
    PillLink(label: "New approach", path: new_approach_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: list_path, label: "Filter approaches", placeholder: "Approach title", values: @filters, clear_path: list_path)
  end

  def approach_row(approach)
    candidates = @stance_counts.fetch(approach.id, 0)
    laws = @policy_counts.fetch(approach.id, 0)
    ListRow(record: approach, title: approach.title,
      meta: "#{approach.issue.title} · #{pluralize(candidates, "candidate")} · #{pluralize(laws, "law")}", detail: approach.description.presence)
  end
end
