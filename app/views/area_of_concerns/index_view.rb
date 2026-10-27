# frozen_string_literal: true

class Views::AreaOfConcerns::IndexView < Views::ApplicationView
  prop :area_of_concerns, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :policy_counts, Hash

  def view_template
    ResourceIndex(collection: @area_of_concerns, pagy: @pagy, heading: "Areas of concern", lede: "The fields laws are grouped into.") do |area|
      ListRow(record: area, title: area.name,
        meta: [ area.policy_domain, pluralize(@policy_counts.fetch(area.id, 0), "law") ].compact_blank.join(" · "), detail: area.description.presence)
    end
  end
end
