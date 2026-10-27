# frozen_string_literal: true

# A section of code: what it says in summary and in full, how it is enforced, and the law it carries out.
class Views::OfficialCodes::ShowView < Views::ApplicationView
  prop :official_code, OfficialCode

  def view_template
    div(class: "record-page policy-page", id: dom_id(@official_code, :show)) do
      PageHeader(title: @official_code.title, trail: trail, eyebrow: eyebrow, lede: @official_code.summary.presence, record: @official_code,
        icon_for: policy, chips: method(:chips))
      div(class: "place-layout") do
        div(class: "place-main") do
          full_text
          enforcement
        end
        aside(class: "place-aside", aria: { label: "About this code" }) do
          facts_card
          admin_card
        end
      end
    end
  end

  private

  def policy
    @official_code.policy
  end

  def trail
    [ [ "Governing bodies", governing_bodies_path ], [ policy.governing_body.name, policy.governing_body ], [ policy.title, policy ] ]
  end

  def eyebrow
    [ "Code", @official_code.code_number ].compact_blank.join(" · ")
  end

  def chips
    StatusChip(status: @official_code.status) if @official_code.status.present?
  end

  def full_text
    section(class: "place-section") do
      section_heading("Full text")
      if @official_code.full_text.present?
        div(class: "code-text") { simple_format(@official_code.full_text) }
      else
        p(class: "card-text") { "The full text of this section is not on Ascent yet." }
      end
    end
  end

  def enforcement
    return if @official_code.enforcement_mechanism.blank? && @official_code.penalty_structure.blank?

    section(class: "place-section") do
      section_heading("Enforcement")
      dl(class: "place-facts-list") do
        FactRow(label: "How") { @official_code.enforcement_mechanism } if @official_code.enforcement_mechanism.present?
        FactRow(label: "Penalties") { @official_code.penalty_structure } if @official_code.penalty_structure.present?
      end
    end
  end

  def facts_card
    SideCard(heading: "About this code") do
      dl(class: "place-facts-list") do
        FactRow(label: "Carries out") { link_to policy.title, policy, class: "text-link" }
        FactRow(label: "Made by") { link_to policy.governing_body.name, policy.governing_body, class: "text-link" }
        FactRow(label: "Effective") { @official_code.effective_date.strftime("%b %-d, %Y") } if @official_code.effective_date
      end
    end
  end

  def admin_card
    return unless current_voter&.admin?

    SideCard(heading: "Admin", modifier: "admin-card") { Ui::ResourceActions(resource: @official_code) }
  end
end
