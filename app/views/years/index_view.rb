# frozen_string_literal: true

class Views::Years::IndexView < Views::ApplicationView
  prop :years, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :election_counts, Hash

  def view_template
    ResourceIndex(collection: @years, pagy: @pagy, lede: "Election years, latest first.") do |year|
      ListRow(record: year, title: year.year.to_s, meta: year_meta(year))
    end
  end

  private

  def year_meta(year)
    [ ("Presidential year" if year.is_presidential_year), ("Even year" if year.is_even_year && !year.is_presidential_year),
      pluralize(@election_counts.fetch(year.id, 0), "election") ].compact.join(" · ")
  end
end
