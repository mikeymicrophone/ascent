# frozen_string_literal: true

# The page for one record of reference data: its name, where it belongs, then the sections its partial
# draws, with its admin actions to the side.
#   ResourceShow(record: @year) { YearPartial(year: @year) }
class Views::Components::ResourceShow < Views::ApplicationView
  prop :record, ActiveRecord::Base
  prop :heading, _Nilable(String)
  prop :lede, _Nilable(String)

  def view_template(&body)
    div(class: "record-page #{model_name.singular.dasherize}-page", id: dom_id(@record, :show)) do
      PageHeader(title: @heading || @record.name.to_s, trail: trail_for(@record), eyebrow: model_name.human, lede: @lede, record: @record)
      div(class: "place-layout") do
        div(class: "place-main", &body)
        admin_aside
      end
    end
  end

  private

  def model_name
    @record.model_name
  end

  def admin_aside
    return unless current_voter&.admin?

    aside(class: "place-aside", aria: { label: "Admin" }) do
      SideCard(heading: "Admin", modifier: "admin-card") { Ui::ResourceActions(resource: @record, show_path: polymorphic_path(@record)) }
    end
  end
end
