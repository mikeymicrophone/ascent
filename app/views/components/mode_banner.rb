# frozen_string_literal: true

# The strip under the navigation that says which kind of election a page is about. The mode names its
# look (ballot, pretend, mock, historical, results); a block adds the note or action at the right.
#   ModeBanner(mode: "mock", label: "Mock election", text: "Invented candidates", icon: :flask_conical) { ... }
class Views::Components::ModeBanner < Views::ApplicationView
  prop :mode, String
  prop :label, String
  prop :text, String
  prop :icon, _Nilable(Symbol)

  def view_template(&aside)
    div(class: "mode-strip mode-#{@mode}", role: "status") do
      div(class: "mode-strip-inner") do
        div(class: "mode-strip-main") do
          icon(@icon, class: "icon mode-strip-icon") if @icon
          span(class: "mode-strip-label") { @label }
          span(class: "mode-strip-text") { @text }
        end
        yield if aside
      end
    end
  end
end
