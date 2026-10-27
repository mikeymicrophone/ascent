# frozen_string_literal: true

class Views::Residences::IndexView < Views::ApplicationView
  prop :residences, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @residences, pagy: @pagy, lede: "Where voters live. Only admins see this list.") do |residence|
      ListRow(record: residence, title: residence.voter.full_name, meta: "#{residence.jurisdiction.name} · #{residence.status.humanize}")
    end
  end
end
