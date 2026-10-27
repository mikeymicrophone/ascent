# frozen_string_literal: true

# The path from a public problem to a position on it: topic, issue, approach, then the candidates who take
# the approach and the laws that put it in place. Shows where the page sits, with the steps above it linked.
#   PolicyPath(approach: approach, current: :approach)
class Views::Components::PolicyPath < Views::ApplicationView
  STEPS = { topic: "Topic", issue: "Issue", approach: "Approach", position: "Stances and laws" }.freeze

  prop :topic, _Nilable(Topic)
  prop :issue, _Nilable(Issue)
  prop :approach, _Nilable(Approach)
  prop :current, _Union(:topic, :issue, :approach, :position)

  def after_initialize
    @issue ||= @approach&.issue
    @topic ||= @issue&.topic
  end

  def view_template
    nav(class: "policy-path", aria: { label: "From a topic to the positions on it" }) do
      ol(class: "policy-path-steps") { STEPS.each { |step, label| path_step(step, label) } }
    end
  end

  private

  def path_step(step, label)
    record = { topic: @topic, issue: @issue, approach: @approach }[step]
    state = if step == @current then "is-current"
    elsif STEPS.keys.index(step) < STEPS.keys.index(@current) then "is-above"
    else "is-below"
    end
    li(class: "policy-path-step #{state}", aria: { current: (step == @current ? "step" : nil) }) do
      span(class: "policy-path-label") { label }
      step_name(record, step)
    end
  end

  def step_name(record, step)
    if record && step != @current
      link_to record.title, record, class: "policy-path-name"
    elsif record
      span(class: "policy-path-name") { record.title }
    else
      span(class: "policy-path-name policy-path-hint") { step == :position ? "Who takes it, and where it is law" : "—" }
    end
  end
end
