# frozen_string_literal: true

# The county and the House, state senate and state assembly districts for a claim: each one known, or a
# list to pick from when the town is split or its boundaries aren't mapped, or a note when there's none.
class Views::ResidenceClaims::AreaFields < Views::ApplicationView
  prop :claim, ResidenceClaim

  def view_template
    dl(class: "place-facts-list claim-districts") do
      ResidenceClaim::AREAS.each { area_row(it) }
    end
  end

  private

  def area_row(kind)
    FactRow(label: ResidenceClaim::AREA_LABELS.fetch(kind)) do
      if (area = @claim.area(kind))
        plain area.name
        input(type: "hidden", name: field_name(kind), value: area.id)
      elsif @claim.needs_pick?(kind)
        area_select(kind)
      else
        span(class: "claim-place-meta") { "None here" }
      end
    end
  end

  def area_select(kind)
    label(for: "claim-#{kind}", class: "visually-hidden") { ResidenceClaim::AREA_LABELS.fetch(kind) }
    select(id: "claim-#{kind}", name: field_name(kind), class: "text-input claim-select") do
      option(value: "") { "I'm not sure" }
      @claim.area_choices(kind).each { |area| option(value: area.id) { area.name } }
    end
  end

  def field_name(kind)
    "#{Residence::AREA_SLOTS.fetch(kind)}_id"
  end
end
