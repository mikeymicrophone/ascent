# frozen_string_literal: true

# Setting where you live: use this device's location or a street address, which find your districts
# too, or search for your city or town. Either way the next page shows what it puts on your ballot before anything saves.
# The preview answers a POST with a page rather than a redirect, so its forms skip Turbo.
class Views::ResidenceClaims::NewView < Views::ApplicationView
  prop :query, String
  prop :places, Array
  prop :residences, Array

  def view_template
    div(class: "claim-page") do
      header(class: "claim-header") do
        span(class: "eyebrow") do
          icon(:map_pin)
          plain "Where you live"
        end
        h1(class: "display-title") { @residences.any? ? "Add or change where you live" : "Set your residence" }
        p(class: "ballot-lede") { "Your ballot comes from where you live: your city or town, your county, and the districts you vote in." }
        current_residences if @residences.any?
        PillLink(label: "Where you've lived", path: past_residences_path, icon: :history, variant: "ghost")
      end
      div(class: "claim-options") do
        location_option
        address_option
        search_option
      end
      privacy_note
    end
  end

  private

  def current_residences
    p(class: "claim-current") do
      plain "Now: "
      @residences.each_with_index do |residence, index|
        plain(", ") if index.positive?
        strong { residence.jurisdiction.name }
        plain " since #{residence.started_on.strftime("%B %Y")}"
      end
    end
  end

  def location_option
    section(class: "form-card claim-option", data: { controller: "locate" }) do
      h2(class: "card-title") { "Use my location" }
      p(class: "card-text") { "Your browser asks once. We find your city and every district whose boundary covers you, then forget the point." }
      form_with(url: preview_residence_claim_path, data: { locate_target: "form", turbo: false }) do
        input(type: "hidden", name: "latitude", data: { locate_target: "latitude" })
        input(type: "hidden", name: "longitude", data: { locate_target: "longitude" })
        button(type: "button", class: "pill-button pill-button-summit", data: { action: "locate#locate", locate_target: "button" }) do
          icon(:locate_fixed)
          plain "Use my location"
        end
      end
      p(class: "claim-status", role: "status", aria: { live: "polite" }, data: { locate_target: "status" })
    end
  end

  def address_option
    section(class: "form-card claim-option") do
      h2(class: "card-title") { "Use my street address" }
      p(class: "card-text") { "The U.S. Census Bureau's geocoder turns it into a point. We find your city and every district that covers it, then forget the address and the point." }
      form_with(url: preview_residence_claim_path, class: "place-search", data: { turbo: false }) do
        label(for: "claim-address", class: "place-search-label") { "Street address, city and state" }
        div(class: "place-search-row") do
          input(id: "claim-address", type: "text", name: "address", required: true, autocomplete: "street-address",
            placeholder: "12 Harbor St, Ansonia, CT", class: "place-search-input")
          button(type: "submit", class: "pill-button") { "Find my districts" }
        end
      end
    end
  end

  def search_option
    section(class: "form-card claim-option") do
      h2(class: "card-title") { "Search for your city or town" }
      p(class: "card-text") { "Choosing a place finds its county and state. Districts need your location or address." }
      form(action: new_residence_claim_path, method: "get", role: "search", class: "place-search") do
        label(for: "claim-search", class: "place-search-label") { "City, town or county" }
        div(class: "place-search-row") do
          input(id: "claim-search", type: "search", name: "q", value: @query, placeholder: "Ansonia", class: "place-search-input")
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
      ul(class: "claim-places") { @places.each { place_choice(it) } }
    end
  end

  def place_choice(place)
    li(class: "claim-place") do
      div(class: "claim-place-text") do
        strong { place.name }
        span(class: "claim-place-meta") { place.place_description }
      end
      form_with(url: preview_residence_claim_path, class: "inline-form", data: { turbo: false }) do
        input(type: "hidden", name: "jurisdiction_id", value: place.id)
        button(type: "submit", class: "pill-button pill-button-outline") { "I live here" }
      end
    end
  end

  def privacy_note
    section(class: "privacy-note") do
      icon(:lock)
      p do
        strong { "Your location stays yours. " }
        plain "We keep the places you live in, not your address or where you stood when you set them. Only you see your residence."
      end
    end
  end
end
