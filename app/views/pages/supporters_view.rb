# frozen_string_literal: true

class Views::Pages::SupportersView < Views::ApplicationView
  def initialize(active_elections:, metrics:)
    @active_elections = active_elections
    @metrics = metrics
  end

  def view_template
    div(class: "story-page supporters-page") do
      render_intro
      render_funding_case
      render_values_case
      render_support_targets
      render_election_preview
    end
  end

  private

  def render_intro
    section(class: "story-hero story-hero-supporters") do
      p(class: "story-kicker") { "For philanthropic partners" }
      h1(class: "story-title") { "Ascent is building public-interest infrastructure for studying better ballots and clearer governance." }
      p(class: "story-lead") do
        "The project is useful to donors who want civic work that can be examined from more than one ideological angle: it is focused on voter expression, administrative clarity, and transparent local experimentation."
      end

      div(class: "story-actions") do
        link_to "See the Live Interface", mountains_path, class: "btn-primary"
        link_to "Return to Overview", root_path, class: "btn-tertiary"
      end
    end
  end

  def render_funding_case
    section(class: "story-section") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { "Why philanthropic capital matters" }
        h2(class: "story-section-title") { "This kind of civic product benefits from patient funding before it can prove itself at scale." }
      end

      div(class: "story-card-grid") do
        render_case_card("Research-grade prototypes", "The platform can host comparative election experiments without forcing a municipality to adopt a reform before the evidence exists.")
        render_case_card("Public explanation", "The mountain interface and linked policy data make abstract election design questions easier to explain to voters, journalists, and civic leaders.")
        render_case_card("Local pilots", "Support can fund small, auditable pilots in specific jurisdictions where the tradeoffs of expressive ballots can be observed in practice.")
      end
    end
  end

  def render_values_case
    section(class: "story-band") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { "Built to earn trust across ideological lines" }
        h2(class: "story-section-title") { "The value proposition is civic capacity, not party advantage." }
      end

      div(class: "story-card-grid story-card-grid-compact") do
        render_case_card("Choice and competition", "People concerned about the spoiler effect can inspect whether broader voter choice produces stronger consensus outcomes.")
        render_case_card("Accountability and restraint", "People concerned about governmental overreach can trace promises back to the actual office that has legal authority to act.")
        render_case_card("Administrative legibility", "Election data, offices, voters, and policy issues live in one schema, which creates a cleaner base for audits and public explanation.")
        render_case_card("Practical experimentation", "The project treats reform as something to be tested in simulations and pilots rather than sold as a slogan.")
      end
    end
  end

  def render_support_targets
    section(class: "story-section") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { "What support could fund next" }
        h2(class: "story-section-title") { "A grant can sharpen both the product and the evidence around it." }
      end

      div(class: "story-support-grid") do
        render_support_target("Test harnesses and model specs", "Improve reliability around election aggregation, simulation, and data integrity so demonstrations are credible under scrutiny.")
        render_support_target("Public-facing narratives", "Expand explainer pages, walkthroughs, and example elections so non-technical stakeholders can evaluate the concept quickly.")
        render_support_target("Seed datasets and demos", "Create richer mock jurisdictions, offices, and policy issue trees that make the mountain interface feel concrete rather than abstract.")
      end
    end
  end

  def render_election_preview
    section(class: "story-section") do
      article(class: "story-callout") do
        h2(class: "story-callout-title") { "Current footprint" }
        p(class: "story-callout-copy") do
          "The repository currently models #{@metrics[:active_elections]} active elections, #{@metrics[:offices]} offices, #{@metrics[:topics]} topics, and #{@metrics[:issues]} issues."
        end

        if @active_elections.any?
          div(class: "story-election-grid") do
            @active_elections.each do |election|
              article(class: "story-election-card story-election-card-inline") do
                p(class: "story-election-context") { election_context(election) }
                h3(class: "story-election-title") { election.name }
                div(class: "story-card-actions") do
                  link_to "Open Mountain", mountain_path(election), class: "btn-primary"
                end
              end
            end
          end
        else
          div(class: "story-card-actions") do
            link_to "Browse Elections", elections_path, class: "btn-secondary"
            link_to "Inspect Jurisdictions", countries_path, class: "btn-tertiary"
          end
        end
      end
    end
  end

  def render_case_card(title, copy)
    article(class: "story-card") do
      h3(class: "story-card-title") { title }
      p(class: "story-card-copy") { copy }
    end
  end

  def render_support_target(title, copy)
    article(class: "story-support-card") do
      h3(class: "story-card-title") { title }
      p(class: "story-card-copy") { copy }
    end
  end
end
