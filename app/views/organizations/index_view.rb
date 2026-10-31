# frozen_string_literal: true

class Views::Organizations::IndexView < Views::ApplicationView
  prop :organizations, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filters, Hash
  prop :states, ActiveRecord::Relation
  prop :parties, _Boolean

  def view_template
    IndexPage(title: @parties ? "Parties" : "Organizations", records: @organizations, pagy: @pagy,
      noun: @parties ? "party" : "organization", frame: "organizations-list", eyebrow: "Elections",
      lede: @parties ? "State parties, their endorsements and the offices they nominate candidates for." : "The parties, unions, advocacy groups and other institutions behind candidates.",
      clear_path: list_path, filters: method(:filter_form)) do |organization|
      ListRow(record: organization, title: organization.name,
        meta: [ organization.is_a?(Party) ? "Party" : organization.kind.humanize, organization.state&.name, organization.abbreviation.presence ].compact.join(" · "))
    end
  end

  private

  def list_path
    @parties ? parties_path : organizations_path
  end

  def filter_form
    selects = [ [ :state_id, "State", @states.map { [ it.name, it.id ] }, "All states" ] ]
    selects << [ :kind, "Kind", [ [ "Party", "party" ], *Organization::KINDS.map { [ it.humanize, it ] } ], "Every kind" ] unless @parties
    FilterForm(url: list_path, label: "Filter #{@parties ? "parties" : "organizations"}", placeholder: "Name or abbreviation",
      values: @filters, clear_path: list_path, selects: selects, submit_on_change: true)
  end
end
