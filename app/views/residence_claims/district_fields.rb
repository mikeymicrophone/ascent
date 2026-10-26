# frozen_string_literal: true

# The House, state senate and state assembly districts for a claim: each one known, or a list to pick
# from when the town is split or its districts aren't mapped, or a note when the state has none.
class Views::ResidenceClaims::DistrictFields < Views::ApplicationView
  prop :claim, ResidenceClaim

  def view_template
    dl(class: "place-facts-list claim-districts") do
      ResidenceClaim::CHAMBERS.each { district_row(it) }
    end
  end

  private

  def district_row(chamber)
    FactRow(label: ResidenceClaim::CHAMBER_LABELS.fetch(chamber)) do
      if (district = @claim.district(chamber))
        plain district.name
        input(type: "hidden", name: "#{chamber}_district_id", value: district.id)
      elsif @claim.needs_pick?(chamber)
        district_select(chamber)
      else
        span(class: "claim-place-meta") { "None here" }
      end
    end
  end

  def district_select(chamber)
    label(for: "claim-#{chamber}", class: "visually-hidden") { ResidenceClaim::CHAMBER_LABELS.fetch(chamber) }
    select(id: "claim-#{chamber}", name: "#{chamber}_district_id", class: "text-input claim-select") do
      option(value: "") { "I'm not sure" }
      @claim.district_choices(chamber).each { |district| option(value: district.id) { district.name } }
    end
  end
end
