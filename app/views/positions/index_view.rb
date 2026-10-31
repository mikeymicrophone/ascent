# frozen_string_literal: true

class Views::Positions::IndexView < Views::ApplicationView
  prop :positions, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :office_counts, Hash

  def view_template
    ResourceIndex(collection: @positions, pagy: @pagy, lede: "The titles offices are held under, from mayor to justice.") do |position|
      ListRow(record: position, title: position.title, meta: position_meta(position), detail: position.description.presence)
    end
  end

  private

  def position_meta(position)
    [ position.branch&.humanize, (pluralize(position.term_length_years, "year term") if position.term_length_years),
      pluralize(@office_counts.fetch(position.id, 0), "office") ].compact.join(" · ")
  end
end
