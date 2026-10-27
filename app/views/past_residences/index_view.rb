# frozen_string_literal: true

# Where a voter has lived: the places they live now and past ones, newest first, each a town with its
# districts and dates. Elections that admit former residents read this history.
class Views::PastResidences::IndexView < Views::ApplicationView
  prop :residences, Array
  prop :query, String
  prop :places, Array

  def view_template
    div(class: "claim-page") do
      header(class: "claim-header") do
        span(class: "eyebrow") do
          icon(:history)
          plain "Your history"
        end
        h1(class: "display-title") { "Where you've lived" }
        p(class: "ballot-lede") { "Some elections let former residents take part. Add the places you used to live, with roughly when." }
      end
      timeline
      add_current_residence if @residences.any?(&:current?)
      add_past_residence
    end
  end

  private

  def timeline
    if @residences.empty?
      section(class: "ballot-empty") do
        p { "You haven't set where you live yet." }
        PillLink(label: "Set where you live", path: new_residence_claim_path, icon: :map_pin)
      end
    else
      ol(class: "residence-timeline") { @residences.each { residence_item(it) } }
    end
  end

  def residence_item(residence)
    li(class: "residence-item#{" is-current" unless residence.ended_on}") do
      div(class: "residence-item-text") do
        span(class: "residence-dates") { dates(residence) }
        strong(class: "residence-town") { residence.jurisdiction.name }
        span(class: "claim-place-meta") { residence.surroundings.map(&:name).join(" · ") }
        ul(class: "chip-list") { residence.districts.each { |district| li(class: "place-chip") { district.name } } } if residence.districts.any?
      end
      residence_action(residence)
    end
  end

  def dates(residence)
    from = residence.started_on.strftime("%b %Y")
    residence.ended_on ? "#{from} – #{residence.ended_on.strftime("%b %Y")}" : "#{from} – now"
  end

  def residence_action(residence)
    if residence.ended_on
      button_to "Remove", past_residence_path(residence), method: :delete, class: "pill-button pill-button-ghost",
        form_class: "inline-form", data: { turbo_confirm: "Remove #{residence.jurisdiction.name} from where you've lived?" }
    else
      button_to "Moved out", move_out_past_residence_path(residence), method: :patch, class: "pill-button pill-button-outline",
        form_class: "inline-form", data: { turbo_confirm: "Did you move out of #{residence.jurisdiction.name} today?" }
    end
  end

  def add_current_residence
    p(class: "claim-current") do
      plain "Live in more than one place? "
      link_to "Add another place you live", new_residence_claim_path
    end
  end

  def add_past_residence
    section(class: "form-card claim-option") do
      h2(class: "card-title") { "Add a place you used to live" }
      form(action: past_residences_path, method: "get", role: "search", class: "place-search") do
        label(for: "history-search", class: "place-search-label") { "City, town or county" }
        div(class: "place-search-row") do
          input(id: "history-search", type: "search", name: "q", value: @query, placeholder: "Where did you live?", class: "place-search-input")
          button(type: "submit", class: "pill-button") { "Search" }
        end
      end
      search_results if @query.present?
    end
  end

  def search_results
    if @places.empty?
      p(class: "card-text") { "No city, town or county matches “#{@query}”." }
    else
      ul(class: "claim-places") do
        @places.each do |place|
          li(class: "claim-place") do
            div(class: "claim-place-text") do
              strong { place.name }
              span(class: "claim-place-meta") { place.place_description }
            end
            PillLink(label: "I lived here", path: new_past_residence_path(jurisdiction_id: place.id), variant: "outline")
          end
        end
      end
    end
  end
end
