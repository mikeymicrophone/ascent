# frozen_string_literal: true

class Views::Pages::GlossaryView < Views::ApplicationView
  FLOW_CARDS = [
    {
      title: "Geography",
      chain: "Country -> State -> City",
      copy: "These are the currently modeled jurisdiction records. Offices, residences, and governing bodies attach back to them polymorphically."
    },
    {
      title: "Election structure",
      chain: "Position -> Office -> Election -> Candidacy",
      copy: "A reusable role becomes a concrete seat in a place, then a contest, then a candidate's run in that contest."
    },
    {
      title: "Voter input",
      chain: "Voter -> Residence -> Rating -> VoterElectionBaseline",
      copy: "Residences establish voter context, ratings express preference, and baselines convert those ratings into approvals."
    },
    {
      title: "Policy chain",
      chain: "Topic -> Issue -> Approach -> Stance -> Policy -> OfficialCode",
      copy: "Broad subjects narrow into problems, proposed responses, candidate positions, enacted policy records, and eventually codified text."
    },
    {
      title: "Rule extraction",
      chain: "Rule::Topic -> Rule::Statement -> Rule::Condition -> Rule::SourceLink",
      copy: "The law-oriented namespace stores normalized rule summaries and the links back to source material."
    }
  ].freeze

  GLOSSARY_SECTIONS = [
    {
      kicker: "Places and offices",
      title: "How the schema names jurisdictions, roles, and contests.",
      entries: [
        {
          term: "Jurisdiction",
          definition: "A shared concept used by Office, Residence, and GoverningBody. It is not its own table in the current schema; it is a polymorphic link to Country, State, or City."
        },
        {
          term: "Country",
          definition: "The top-level geographic record. Countries own states and can also directly own offices and residences."
        },
        {
          term: "State",
          definition: "A subnational jurisdiction that belongs to a country. States own cities and can also directly own offices and residences."
        },
        {
          term: "City",
          definition: "A local jurisdiction that belongs to a state. Cities can hold offices, elections, and voter residences."
        },
        {
          term: "Position",
          definition: "A reusable role title such as Mayor, Senator, or Justice. Each position belongs to a branch: legislative, executive, or judicial."
        },
        {
          term: "Office",
          definition: "A concrete seat formed by pairing a Position with a jurisdiction. An office can also sit in a GoverningBody, and in a Chamber when that body has houses."
        },
        {
          term: "Year",
          definition: "The election-cycle container. Elections belong to a year so the app can group contests and compare cycles."
        },
        {
          term: "Election",
          definition: "One contest for one office in one year. Elections carry the date and status, and they collect candidacies and voter baselines."
        }
      ]
    },
    {
      kicker: "People and participation",
      title: "How the schema distinguishes identities, eligibility, and expressive voting.",
      entries: [
        {
          term: "Person",
          definition: "A real individual who can appear in elections as a candidate. This is separate from Voter so the system does not assume every candidate is an authenticated participant."
        },
        {
          term: "Voter",
          definition: "An authenticated participant in the system. Voters own residences, ratings, and per-election baselines."
        },
        {
          term: "Residence",
          definition: "The voter-to-jurisdiction record used for location and eligibility history. In current code this fills the role that older notes sometimes called registration."
        },
        {
          term: "Candidacy",
          definition: "A person's run in a specific election. The same person can have many candidacies across different elections."
        },
        {
          term: "Rating",
          definition: "A voter's 0-500 score for one candidacy. Ratings capture intensity of support before they are converted into approvals."
        },
        {
          term: "VoterElectionBaseline",
          definition: "A voter's approval threshold for one election. Any candidate in that election with a rating at or above the baseline counts as approved."
        },
        {
          term: "RatingArchive",
          definition: "A historical snapshot of a prior rating value. The app writes these records when an existing rating changes."
        },
        {
          term: "VoterElectionBaselineArchive",
          definition: "A historical record of baseline changes or deletions for one voter-election pair."
        },
        {
          term: "Mountain",
          definition: "A derived interface concept rather than a table. It visualizes how ratings and a baseline interact inside one election."
        }
      ]
    },
    {
      kicker: "Policy and governance",
      title: "How public problems connect to institutions, proposals, and codified text.",
      entries: [
        {
          term: "Branch",
          definition: "Legislative, executive, or judicial. The same three branches apply at every level. A school board or special district can be a governing body with no branch."
        },
        {
          term: "GovernanceType",
          definition: "The form of an institution, independent of level: Legislature, Court, Council, Board, or Executive. Congress and a state legislature share the Legislature type."
        },
        {
          term: "GoverningBody",
          definition: "An institution in a jurisdiction, such as a state legislature or a state supreme court. It has a governance type, an optional branch, and owns policies."
        },
        {
          term: "Chamber",
          definition: "A house of a governing body. A bicameral legislature stays one body; its Senate and Assembly or House are chambers. Seats in a house belong to that chamber."
        },
        {
          term: "AreaOfConcern",
          definition: "A policy domain such as housing, transportation, or public safety. This is how the schema groups what a policy is about."
        },
        {
          term: "Topic",
          definition: "A broad subject area for civic discussion. Topics are parents of issues."
        },
        {
          term: "Issue",
          definition: "A specific problem or dispute inside a topic. Issues are narrower than topics and are parents of approaches."
        },
        {
          term: "Approach",
          definition: "A proposed response to an issue. Approaches are what candidates take stances on and what policies can later operationalize."
        },
        {
          term: "Stance",
          definition: "A candidacy's position on an approach. This is the schema's bridge between electoral competition and policy substance."
        },
        {
          term: "Policy",
          definition: "A concrete governing record that ties together a governing body, an area of concern, and an approach."
        },
        {
          term: "OfficialCode",
          definition: "Codified or operative text attached to a policy, including summaries, enforcement notes, and full text where available."
        }
      ]
    },
    {
      kicker: "Rule analysis",
      title: "How the legal-analysis namespace differs from the general policy vocabulary.",
      entries: [
        {
          term: "Rule::Topic",
          definition: "A law-oriented grouping for normalized rule content. Separate namespace from the general Topic model."
        },
        {
          term: "Rule::Statement",
          definition: "A normalized statement about what is allowed, prohibited, conditional, exception-limited, or unclear."
        },
        {
          term: "Rule::Condition",
          definition: "A qualifier attached to a rule statement, such as a requirement, clarification, or disqualifying fact."
        },
        {
          term: "Rule::SourceLink",
          definition: "A provenance record that connects a normalized rule statement or condition back to a source-law unit."
        },
        {
          term: "LU unit reference",
          definition: "The lu_unit_id stored on Rule::SourceLink points to a source-law record in the planned LU namespace. That source object is referenced here but not stored in this database."
        }
      ]
    }
  ].freeze

  def view_template
    div(class: "story-page glossary-page") do
      render_intro
      render_flow_cards
      GLOSSARY_SECTIONS.each { render_section(it) }
    end
  end

  private

  def render_intro
    section(class: "story-hero") do
      p(class: "story-kicker") { "Schema glossary" }
      h1(class: "story-title") { "How the current data model names the civic concepts in Ascent." }
      p(class: "story-lead") do
        "The quickest summary is: positions become offices, offices get elections, people form candidacies, voters create ratings and baselines, and governance records connect issues to real institutions and code."
      end

      div(class: "story-actions") do
        link_to "Browse Elections", elections_path, class: "btn-primary"
        link_to "Inspect Governance Data", governing_bodies_path, class: "btn-secondary"
        link_to "Return to Overview", root_path, class: "btn-tertiary"
      end
    end
  end

  def render_flow_cards
    section(class: "story-band") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { "Fast orientation" }
        h2(class: "story-section-title") { "Five relationship chains explain most of the schema." }
      end

      div(class: "story-card-grid") do
        FLOW_CARDS.each do |card|
          article(class: "story-card story-card-subtle") do
            p(class: "story-section-kicker") { card[:title] }
            h3(class: "story-card-title") { card[:chain] }
            p(class: "story-card-copy") { card[:copy] }
          end
        end
      end
    end
  end

  def render_section(section_data)
    section(class: "story-section") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { section_data[:kicker] }
        h2(class: "story-section-title") { section_data[:title] }
      end

      div(class: "story-card-grid") do
        section_data[:entries].each do |entry|
          render_entry(entry)
        end
      end
    end
  end

  def render_entry(entry)
    article(class: "story-card") do
      h3(class: "story-card-title") { entry[:term] }
      p(class: "story-card-copy") { entry[:definition] }
    end
  end
end
