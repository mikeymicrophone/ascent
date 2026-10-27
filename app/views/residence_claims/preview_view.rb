# frozen_string_literal: true

# Before saving, the voter sees where the claim places them and what that puts on their ballot.
class Views::ResidenceClaims::PreviewView < Views::ApplicationView
  LEVEL_LABELS = { "city" => "city", "county" => "county", "state" => "state", "federal" => "federal" }.freeze

  prop :claim, ResidenceClaim

  def view_template
    div(class: "claim-page") do
      @claim.valid? ? confirmation : not_found
    end
  end

  private

  def confirmation
    header(class: "claim-header") do
      span(class: "eyebrow") { "Check this is right" }
      h1(class: "display-title") { @claim.town.name }
      p(class: "ballot-lede") { lede }
    end
    section(class: "form-card claim-summary") do
      h2(class: "card-heading") { "Your places" }
      ul(class: "chip-list") { places.each { |place| li(class: "place-chip#{" is-district" if @claim.areas.except("county").value?(place)}") { place.name } } }
      p(class: "card-text") { district_note }
      form_with(url: residence_claim_path, class: "claim-confirm") do
        h2(class: "card-heading") { "Your county and districts" }
        AreaFields(claim: @claim)
        h2(class: "card-heading") { "On your ballot now" }
        ballot_counts
        confirm_actions
      end
    end
  end

  def lede
    if @claim.from_address?
      "The Census matched #{@claim.matched_address}, which falls in #{@claim.town.name}."
    elsif @claim.from_location?
      "Your location falls in #{@claim.town.name}."
    else
      "You chose #{@claim.town.name}."
    end
  end

  def places
    @claim.ballot_jurisdictions.includes(:jurisdictionable).sort_by { [ Jurisdiction::BALLOT_LEVELS.index(it.ballot_level) || Jurisdiction::BALLOT_LEVELS.size, it.name ] }
  end

  def district_note
    if @claim.from_location?
      "Your districts come from the boundaries we hold. Pick any we couldn't place."
    else
      "Where your town sits in one district we fill it in. Where it's split, pick yours, or use your location instead."
    end
  end

  def ballot_counts
    counts = @claim.open_race_counts
    if counts.empty?
      p(class: "card-text") { "No races are open where you live right now." }
    else
      div(class: "stat-tiles") do
        counts.each { |level, count| StatTile(value: count.to_s, label: "#{LEVEL_LABELS.fetch(level)} #{"race".pluralize(count)}") }
      end
    end
  end

  # Districts already placed go back as their ids; the town goes back as itself, never the location.
  # A voter who already lives somewhere says whether they moved here or live here as well.
  def confirm_actions
    input(type: "hidden", name: "jurisdiction_id", value: @claim.town.id)
    div(class: "form-actions") do
      if @claim.voter.current_residences.exists?
        button(type: "submit", name: "moving", value: "1", class: "pill-button pill-button-summit") { "I moved here" }
        button(type: "submit", name: "moving", value: "0", class: "pill-button pill-button-outline") { "I also live here" }
      else
        button(type: "submit", class: "pill-button pill-button-summit") { "Make this my residence" }
      end
      PillLink(label: "Not right? Choose again", path: new_residence_claim_path, variant: "ghost")
    end
  end

  def not_found
    section(class: "ballot-empty") do
      h1(class: "card-title") { "We couldn't place that" }
      p { @claim.errors.full_messages.to_sentence }
      PillLink(label: "Search for your city or town", path: new_residence_claim_path)
    end
  end
end
