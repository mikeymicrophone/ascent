# frozen_string_literal: true

# Every issue, or a topic's issues: search by title or narrow to a topic. Each row counts the approaches to it.
class Views::Issues::IndexView < Views::ApplicationView
  prop :issues, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(Topic)
  prop :filters, Hash
  prop :topics, ActiveRecord::Relation
  prop :approach_counts, Hash

  def view_template
    IndexPage(title: @parent ? "Issues in #{@parent.title}" : "Issues", records: @issues, pagy: @pagy, noun: "issue", frame: "issues-list",
      eyebrow: "Policy", lede: "The public problems within each topic. Open one to see the ways to address it.",
      trail: [ [ "Topics", topics_path ], *([ [ @parent.title, @parent ] ] if @parent) ], clear_path: list_path,
      actions: (method(:new_issue_link) if scaffold_new_resource_visible?(Issue)), filters: method(:filter_form)) { issue_row(it) }
  end

  private

  def list_path
    @parent ? topic_issues_path(@parent) : issues_path
  end

  def new_issue_link
    PillLink(label: "New issue", path: new_issue_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: list_path, label: "Filter issues", placeholder: "Issue title", values: @filters, clear_path: list_path,
      selects: (@parent ? [] : [ [ :topic_id, "Topic", @topics.map { [ it.title, it.id ] }, "Every topic" ] ]))
  end

  def issue_row(issue)
    approaches = @approach_counts.fetch(issue.id, 0)
    ListRow(record: issue, title: issue.title, meta: "#{issue.topic.title} · #{pluralize(approaches, "approach", plural: "approaches")}",
      detail: issue.description.presence)
  end
end
