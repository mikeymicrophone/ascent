# frozen_string_literal: true

# Make a mock election: invented races and candidates in a real place, for a class or a test.
class Views::MockElections::NewView < Views::ApplicationView
  RACE_SLOTS = 3

  prop :mock_election, MockElection
  prop :places, Array

  def view_template
    div(class: "mock-page") do
      ModeBanner(mode: "mock", label: "Mock election", text: "Invented candidates, kept apart from real races and real people",
        icon: :flask_conical) { span(class: "mode-strip-note") { "Not a real race" } }
      div(class: "mock-body") do
        header(class: "mock-header") do
          span(class: "eyebrow") { "New" }
          h1(class: "display-title") { "Make a mock election" }
          p(class: "ballot-lede") { "Set up a race for a class, a club or a test. Anyone can build a mountain for it, and it never counts with real results." }
        end
        mock_form
      end
    end
  end

  private

  def mock_form
    form_with(url: mock_elections_path, class: "mock-form") do
      div(class: "form-card") do
        field("Name") { input(type: "text", name: "mock_election[name]", value: @mock_election.name, required: true, placeholder: "School board, classroom edition", class: "text-input") }
        field("Description") { textarea(name: "mock_election[description]", rows: 2, placeholder: "Who it's for and what it's testing", class: "text-input") { @mock_election.description } }
        div(class: "form-row") do
          field("Election day") { input(type: "date", name: "mock_election[election_date]", value: @mock_election.election_date&.iso8601, required: true, class: "text-input") }
          field("Place") { place_select }
        end
      end
      RACE_SLOTS.times { race_fields(it) }
      div(class: "form-actions") do
        button(type: "submit", class: "pill-button pill-button-summit") { "Create mock election" }
        PillLink(label: "Cancel", path: ballot_path, variant: "ghost")
      end
    end
  end

  def place_select
    select(name: "mock_election[jurisdiction_id]", class: "text-input") do
      @places.each { |place| option(value: place.id, selected: place == @places.first) { place.name } }
    end
  end

  def race_fields(index)
    first = index.zero?
    fieldset(class: "form-card race-fields") do
      legend(class: "card-title") { first ? "Race" : "Another race (optional)" }
      field("Office") { input(type: "text", name: "mock_election[races][][title]", placeholder: ("School Board" if first), required: first, class: "text-input") }
      field("Candidates, one per line") do
        textarea(name: "mock_election[races][][candidates]", rows: 4, placeholder: ("Avery Lin\nJordan Okafor-Reyes" if first), required: first, class: "text-input")
      end
    end
  end

  def field(label_text, &)
    label(class: "form-field") do
      span(class: "form-label") { label_text }
      yield
    end
  end
end
