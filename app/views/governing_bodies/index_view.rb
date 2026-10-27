# frozen_string_literal: true

# Every governing body, or one kind's: search by name or narrow by kind. Each row says where it governs
# and how many of its laws are on Ascent.
class Views::GoverningBodies::IndexView < Views::ApplicationView
  prop :governing_bodies, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(GovernanceType)
  prop :filters, Hash
  prop :governance_types, ActiveRecord::Relation
  prop :policy_counts, Hash

  def view_template
    IndexPage(title: @parent ? "Governing bodies for #{@parent.name}" : "Governing bodies", records: @governing_bodies, pagy: @pagy,
      noun: "governing body", frame: "governing-bodies-list", eyebrow: "Governance",
      lede: "The councils, legislatures, courts and offices that make and carry out laws, and the laws of theirs on Ascent.",
      trail: @parent ? [ [ "Governing bodies", governing_bodies_path ] ] : [ [ "Governance types", governance_types_path ] ],
      clear_path: list_path, actions: (method(:new_body_link) if scaffold_new_resource_visible?(GoverningBody)), filters: method(:filter_form)) { body_row(it) }
  end

  private

  def list_path
    @parent ? governance_type_governing_bodies_path(@parent) : governing_bodies_path
  end

  def new_body_link
    PillLink(label: "New governing body", path: new_governing_body_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: list_path, label: "Filter governing bodies", placeholder: "Name", values: @filters, clear_path: list_path,
      selects: (@parent ? [] : [ [ :governance_type_id, "Kind", @governance_types.map { [ it.name, it.id ] }, "Every kind" ] ]))
  end

  def body_row(body)
    laws = @policy_counts.fetch(body.id, 0)
    ListRow(record: body, title: body.name,
      meta: [ body.governance_type&.name, body.jurisdiction&.name, pluralize(laws, "law") ].compact.join(" · "), detail: body.description.presence) do
      span(class: "row-badge") { "No longer sits" } unless body.is_active
    end
  end
end
