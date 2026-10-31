# frozen_string_literal: true

# A section of a record's page listing a few related records, with their total and a link to all of them.
#   RelatedList(heading: "Earlier races for this office", records: races.first(5), total: races.size,
#     see_all: office_races_path(office)) { |race| ListRow(record: race, title: race.name) }
# With no records it draws nothing, unless it has an empty line to say why.
class Views::Components::RelatedList < Views::ApplicationView
  prop :heading, String
  prop :records, _Any
  prop :total, Integer
  prop :see_all, _Nilable(String)
  prop :noun, _Nilable(String)
  prop :empty, _Nilable(String)
  prop :id, _Nilable(String)

  def view_template(&row)
    return if @total.zero? && !@empty

    section(class: "place-section related-list", id: @id) do
      div(class: "place-section-heading") do
        h2(class: "card-title") { @heading }
        span(class: "related-list-count") { delimited(@total) } if @total.positive?
      end
      if @total.zero?
        p(class: "card-text") { @empty }
      else
        ul(class: "list-rows", data: { controller: "reveal" }) { @records.each(&row) }
        see_all_link if @see_all && @total > @records.size
      end
    end
  end

  private

  def see_all_link
    link_to @see_all, class: "text-link related-list-all" do
      plain "See all #{delimited(@total)}#{" #{@noun}" if @noun}"
      icon(:chevron_right)
    end
  end
end
