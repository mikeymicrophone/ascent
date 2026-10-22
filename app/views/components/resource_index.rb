# frozen_string_literal: true

# The page around a list of records: heading, new link, one block per record, and the pager.
#   ResourceIndex(collection: @issues, pagy: @pagy) { IssuePartial(issue: it) }
# A list filtered to one parent names it in the heading and links back to the full list:
#   ResourceIndex(collection: @issues, parent: @topic) { ... }
# A list can also set its own heading and details, and put controls beside each record's actions:
#   ResourceIndex(collection: @races, heading: "...", details: -> { ... }, extra_actions: ->(race) { ... })
class Views::Components::ResourceIndex < Views::ApplicationView
  prop :collection, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(ActiveRecord::Base)
  prop :heading, _Nilable(String)
  prop :details, _Callable?
  prop :extra_actions, _Callable?

  def view_template(&item_content)
    div(class: "scaffold #{plural}-index", id: "index_#{plural}") do
      div do
        h1 { @heading || default_heading }
        @parent ? parent_filter_info : @details&.call
        scaffold_new_resource_link "New #{model_name.human.downcase}", new_polymorphic_path(model), record: model
      end

      div(id: plural) do
        if @collection.any?
          @collection.each { list_item(it, &item_content) }
        else
          p { "No #{human_plural.downcase} found." }
        end
      end

      Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def list_item(record)
    div(id: dom_id(record, :list_item)) do
      yield record

      ActionBar(record: record, summary: engagement_summary) if engageable?

      if @extra_actions
        div do
          @extra_actions.call(record)
          whitespace
          Ui::ResourceActions(resource: record)
        end
      else
        Ui::ResourceActions(resource: record)
      end
    end
  end

  def engageable?
    model.include?(Engageable)
  end

  def engagement_summary
    @engagement_summary ||= EngagementSummary.new(@collection.to_a, current_voter)
  end

  def default_heading
    @parent ? "#{human_plural} for #{@parent.name}" : human_plural
  end

  def parent_filter_info
    div(class: "filter-info") do
      span { "Showing #{human_plural.downcase} for " }
      link_to @parent.name, @parent, class: "link #{@parent.model_name.element}"
      span { " - " }
      link_to "View all #{human_plural.downcase}", polymorphic_path(model), class: "link view-all"
    end
  end

  def model
    @collection.model
  end

  def model_name
    model.model_name
  end

  def human_plural
    model_name.human.pluralize
  end

  def plural
    model_name.plural
  end
end
