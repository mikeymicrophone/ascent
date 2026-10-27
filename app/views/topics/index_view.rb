# frozen_string_literal: true

# Every topic, as the first step from a public problem to the positions on it.
class Views::Topics::IndexView < Views::ApplicationView
  prop :topics, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :issue_counts, Hash
  prop :approach_counts, Hash

  def view_template
    IndexPage(title: "Topics", records: @topics, pagy: @pagy, noun: "topic", frame: "topics-list", eyebrow: "Policy",
      lede: "Start from a topic, find an issue within it, then the approaches to it: who takes each one, and where it is already law.",
      actions: (method(:new_topic_link) if allowed_to?(:new?, Topic)), aside: method(:path)) { topic_row(it) }
  end

  private

  def path
    PolicyPath(current: :topic)
  end

  def new_topic_link
    PillLink(label: "New topic", path: new_topic_path, icon: :plus)
  end

  def topic_row(topic)
    issues = @issue_counts.fetch(topic.id, 0)
    approaches = @approach_counts.fetch(topic.id, 0)
    ListRow(record: topic, title: topic.title, meta: "#{pluralize(issues, "issue")} · #{pluralize(approaches, "approach", plural: "approaches")}",
      detail: topic.description.presence)
  end
end
