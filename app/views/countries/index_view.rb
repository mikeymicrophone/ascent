# frozen_string_literal: true

# Every country Ascent covers, with the states in each.
class Views::Countries::IndexView < Views::ApplicationView
  prop :countries, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :state_counts, Hash

  def view_template
    IndexPage(title: "Countries", records: @countries, pagy: @pagy, noun: "country", frame: "countries-list", eyebrow: "Places",
      lede: "The countries Ascent covers. Each leads down through its states to the places where people vote.",
      actions: (method(:new_country_link) if allowed_to?(:new?, Country))) { country_row(it) }
  end

  private

  def new_country_link
    PillLink(label: "New country", path: new_country_path, icon: :plus)
  end

  def country_row(country)
    ListRow(record: country, title: country.name, meta: pluralize(delimited(@state_counts.fetch(country.id, 0)), "state"),
      detail: country.description.presence) do
      span(class: "row-badge") { country.code } if country.code.present?
    end
  end
end
