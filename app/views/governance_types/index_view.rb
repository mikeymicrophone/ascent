# frozen_string_literal: true

class Views::GovernanceTypes::IndexView < Views::ApplicationView
  prop :governance_types, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :body_counts, Hash

  def view_template
    ResourceIndex(collection: @governance_types, pagy: @pagy, lede: "Kinds of governing body, by how they decide.") do |type|
      ListRow(record: type, title: type.name, meta: pluralize(@body_counts.fetch(type.id, 0), "governing body", plural: "governing bodies"),
        detail: type.description.presence)
    end
  end
end
