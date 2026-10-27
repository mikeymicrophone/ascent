# frozen_string_literal: true

# A candidate's stances, grouped by topic: each names the approach they take to an issue, links along the
# chain from topic to issue to approach, and says how much evidence backs it.
#   StanceList(stances: candidacy.stances.includes(:stance_evidences, approach: { issue: :topic }))
class Views::Components::StanceList < Views::ApplicationView
  prop :stances, _Any

  def view_template
    div(class: "stance-groups") do
      @stances.group_by { it.approach.issue.topic }.sort_by { |topic, _| topic.title }.each do |topic, stances|
        section(class: "stance-group") do
          h3(class: "stance-group-title") do
            entity_icon(topic)
            link_to topic.title, topic, class: "text-link"
          end
          ul(class: "list-rows") { stances.each { stance_row(it) } }
        end
      end
    end
  end

  private

  def stance_row(stance)
    ListRow(record: stance, title: stance.approach.title, meta: "On #{stance.approach.issue.title}", detail: stance.explanation.presence) do
      span(class: "row-badge row-badge-priority") { "#{stance.priority_level} priority" } if stance.priority_level.present?
      span(class: "row-badge") { pluralize(stance.stance_evidences.size, "source") } if stance.stance_evidences.any?
    end
  end
end
