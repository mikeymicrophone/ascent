# frozen_string_literal: true

# A governing body's page: the laws it has made, with what each does, and the seats on it, with the side
# column saying what kind of body it is, where, and how it works.
class Views::GoverningBodies::ShowView < Views::ApplicationView
  SEAT_LIMIT = 10

  prop :governing_body, GoverningBody

  def view_template
    div(class: "record-page governance-page", id: dom_id(@governing_body, :show)) do
      PageHeader(title: @governing_body.name, trail: trail, eyebrow: eyebrow, lede: lede, record: @governing_body,
        icon_for: @governing_body, chips: method(:chips))
      stat_tiles
      div(class: "place-layout") do
        div(class: "place-main") do
          policies_section
          seats_section
        end
        aside(class: "place-aside", aria: { label: "About #{@governing_body.name}" }) do
          about_card
          chambers_card
          admin_card
        end
      end
    end
  end

  private

  def place
    @governing_body.jurisdiction.jurisdictionable
  end

  def trail
    [ [ "Governing bodies", governing_bodies_path ], [ place.name, place ] ]
  end

  def eyebrow
    [ @governing_body.governance_type&.name, @governing_body.branch&.humanize ].compact_blank.join(" · ").presence || "Governing body"
  end

  def lede
    @governing_body.description.presence ||
      "#{@governing_body.name} governs #{place.name}, with #{pluralize(offices.size, "seat")} and #{pluralize(policies.size, "law")} on Ascent."
  end

  def chips
    span(class: "row-badge") { "No longer sits" } unless @governing_body.is_active
  end

  def policies
    @policies ||= @governing_body.policies.includes(:area_of_concern, approach: :issue).order(enacted_date: :desc, title: :asc).to_a
  end

  def offices
    @offices ||= @governing_body.offices.includes(:position, :jurisdiction).joins(:position).order("positions.title", :id).to_a
  end

  def stat_tiles
    div(class: "stat-tiles place-facts") do
      StatTile(value: delimited(policies.size), label: "#{"law".pluralize(policies.size)} on Ascent")
      StatTile(value: delimited(policies.count(&:enacted?)), label: "in force")
      StatTile(value: delimited(offices.size), label: "#{"seat".pluralize(offices.size)} on it")
    end
  end

  def policies_section
    RelatedList(heading: "Laws it has made", records: policies, total: policies.size, id: "body-policies",
      empty: "No law made by #{@governing_body.name} is on Ascent yet.") do |policy|
      ListRow(record: policy, title: policy.title, meta: policy_meta(policy), detail: policy.description.presence) do
        StatusChip(status: policy.status)
      end
    end
  end

  def policy_meta(policy)
    [ policy.approach && "Approach: #{policy.approach.title}", policy.enacted_date&.strftime("%b %Y") ].compact.join(" · ")
  end

  def seats_section
    RelatedList(heading: "Seats on it", records: offices.first(SEAT_LIMIT), total: offices.size,
      see_all: offices_path(governing_body_id: @governing_body.id), noun: "seats") do |office|
      ListRow(record: office, title: office.name, meta: office.seat_label)
    end
  end

  def about_card
    SideCard(heading: "About") do
      dl(class: "place-facts-list") do
        FactRow(label: "Kind") { link_to @governing_body.governance_type.name, @governing_body.governance_type, class: "text-link" } if @governing_body.governance_type
        FactRow(label: "Governs") { link_to place.name, place, class: "text-link" }
        FactRow(label: "Branch") { @governing_body.branch.humanize } if @governing_body.branch
        FactRow(label: "Established") { @governing_body.formatted_established_date } if @governing_body.established_date
        FactRow(label: "Meets") { @governing_body.meeting_schedule } if @governing_body.meeting_schedule.present?
      end
    end
  end

  def chambers_card
    chambers = @governing_body.chambers.order(:name).to_a
    return if chambers.empty?

    SideCard(heading: "Chambers") do
      ul(class: "nearby-list") { chambers.each { |chamber| li { chamber.name } } }
    end
  end

  def admin_card
    return unless current_voter&.admin?

    SideCard(heading: "Admin", modifier: "admin-card") do
      Ui::ResourceActions(resource: @governing_body)
      scaffold_new_resource_link "Add a law", new_policy_path, record: Policy
    end
  end
end
