# frozen_string_literal: true

# Adding a past residence: when the voter lived in the town, and its districts in the same shape as a
# current residence.
class Views::PastResidences::NewView < Views::ApplicationView
  prop :claim, ResidenceClaim

  def view_template
    div(class: "claim-page") do
      header(class: "claim-header") do
        span(class: "eyebrow") { "A place you used to live" }
        h1(class: "display-title") { @claim.town&.name || "Choose a place" }
        p(class: "ballot-lede") { "Roughly when is fine. Pick districts if you know them; leave any you don't." }
      end
      @claim.town ? residence_form : PillLink(label: "Search for a place", path: past_residences_path)
    end
  end

  private

  def residence_form
    form_with(url: past_residences_path, class: "form-card claim-confirm") do
      errors if @claim.errors.any?
      input(type: "hidden", name: "jurisdiction_id", value: @claim.town.id)
      div(class: "form-row") do
        date_field("started_on", "Moved in", @claim.started_on)
        date_field("ended_on", "Moved out", @claim.ended_on)
      end
      h2(class: "card-heading") { "Its districts" }
      Views::ResidenceClaims::DistrictFields(claim: @claim)
      div(class: "form-actions") do
        button(type: "submit", class: "pill-button pill-button-summit") { "Add to where I've lived" }
        PillLink(label: "Cancel", path: past_residences_path, variant: "ghost")
      end
    end
  end

  def date_field(name, label_text, value)
    label(class: "form-field") do
      span(class: "form-label") { label_text }
      input(type: "date", name: name, value: value&.iso8601, max: Date.current.iso8601, required: true, class: "text-input")
    end
  end

  def errors
    div(class: "claim-errors", role: "alert") { @claim.errors.full_messages.to_sentence }
  end
end
