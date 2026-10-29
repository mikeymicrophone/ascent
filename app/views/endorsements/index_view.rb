# frozen_string_literal: true

class Views::Endorsements::IndexView < Views::ApplicationView
  prop :endorsements, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash
  prop :organization, _Nilable(Organization)

  def view_template
    IndexPage(title: @organization ? "Endorsements by #{@organization.name}" : "Endorsements", records: @endorsements, pagy: @pagy, noun: "endorsement", frame: "endorsements-list",
      eyebrow: "Elections", lede: "Party lines and public support for candidates, including withdrawn endorsements.",
      clear_path: endorsements_path, filters: method(:filter_form)) { EndorsementRow(endorsement: it) }
  end

  private

  def filter_form
    FilterForm(url: endorsements_path, label: "Filter endorsements", placeholder: "Endorser or candidate name", values: @filters,
      hidden: @filters.slice("organization_id"), clear_path: endorsements_path, submit_on_change: true,
      selects: [
        [ :kind, "Kind", [ [ "Party line", "ballot_line" ], [ "Public endorsement", "public" ] ], "Every kind" ],
        [ :status, "Status", [ [ "Current", "current" ], [ "Withdrawn", "withdrawn" ] ], "Every status" ]
      ])
  end
end
