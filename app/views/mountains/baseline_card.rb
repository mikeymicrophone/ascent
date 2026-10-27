# frozen_string_literal: true

# The baseline's value with buttons to nudge it by ten, and how many saved changes are left today.
class Views::Mountains::BaselineCard < Views::ApplicationView
  prop :mountain, Mountain

  def view_template
    section(class: "side-card baseline-card") do
      h2(class: "card-heading baseline-heading") { "Baseline" }
      div(class: "baseline-stepper") do
        nudge_button(-10, "Lower baseline by 10", :minus)
        span(class: "baseline-value", data: { role: "baseline-value" }) { @mountain.baseline&.to_s || "—" }
        nudge_button(10, "Raise baseline by 10", :plus)
      end
      p(class: "baseline-note") { "Moving your baseline changes who you approve. It never changes a rating." }
      Views::Mountains::BaselineAllowance(mountain: @mountain)
    end
  end

  private

  def nudge_button(step, label, icon_name)
    button(type: "button", class: "stepper-button", aria: { label: label },
      data: { action: "mountain-editor#nudgeBaseline", "mountain-editor-step-param": step }) { icon(icon_name) }
  end
end
