class Views::Partials::StancePartial < Views::ApplicationView
  def initialize(stance:, show_candidacy: true, show_issue: true, show_approach: true)
    @stance = stance
    @show_candidacy = show_candidacy
    @show_issue = show_issue
    @show_approach = show_approach
    @fields = []
    @custom_fields = []
  end

  def view_template(&block)
    if block
      yield(FieldBuilder.new(self))
    else
      build_default_fields
    end
    
    div(id: dom_id(@stance), class: "stance-partial") do
      HierarchicalNavigation(current_object: @stance)

      @fields.each { it[:content].call }
      
      @custom_fields.each do |field|
        div(class: "custom-field") do
          span { "#{field[:label]}:" }
          whitespace
          field[:content].call
        end
      end
    end
  end

  def add_candidacy_field
    @fields << {
      type: :candidacy,
      content: -> {
        h3 do
          link_to @stance.candidacy.person.full_name, @stance.candidacy, class: "link candidacy"
          span(class: "stance-priority stance-priority-#{@stance.priority_level}") { " (#{@stance.priority_level} priority)" }
        end
      }
    }
  end

  def add_issue_field
    @fields << {
      type: :issue,
      content: -> {
        div do
          span { "Issue:" }
          whitespace
          link_to @stance.issue.title, @stance.issue, class: "link issue"
        end
      }
    }
  end

  def add_approach_field
    @fields << {
      type: :approach,
      content: -> {
        div do
          span { "Approach:" }
          whitespace
          link_to @stance.approach.title, @stance.approach, class: "link approach"
        end
      }
    }
  end

  def add_explanation_field
    return unless @stance.explanation.present?
    
    @fields << {
      type: :explanation,
      content: -> {
        div do
          span { "Explanation:" }
          whitespace
          div(class: "mt-1") { simple_format(@stance.explanation) }
        end
      }
    }
  end

  def add_priority_field
    @fields << {
      type: :priority,
      content: -> {
        div do
          span { "Priority level:" }
          whitespace
          span(class: "stance-priority stance-priority-#{@stance.priority_level}") { @stance.priority_level.capitalize }
        end
      }
    }
  end

  def add_evidence_field
    return unless @stance.evidence_links.present?
    
    @fields << {
      type: :evidence,
      content: -> {
        div do
          span { "Evidence links:" }
          whitespace
          div(class: "mt-1") { simple_format(@stance.evidence_links) }
        end
      }
    }
  end

  def add_custom_field(label, &block)
    @custom_fields << {
      label: label,
      content: block
    }
  end

  private

  def build_default_fields
    add_candidacy_field if @show_candidacy
    add_issue_field if @show_issue
    add_approach_field if @show_approach
    add_explanation_field
    add_priority_field unless @show_candidacy
    add_evidence_field
  end

  class FieldBuilder
    def initialize(partial)
      @partial = partial
    end

    def candidacy_field
      @partial.add_candidacy_field
    end

    def issue_field
      @partial.add_issue_field
    end

    def approach_field
      @partial.add_approach_field
    end

    def explanation_field
      @partial.add_explanation_field
    end

    def priority_field
      @partial.add_priority_field
    end

    def evidence_field
      @partial.add_evidence_field
    end

    def custom_field(label, &block)
      @partial.add_custom_field(label, &block)
    end
  end
end