class Views::Approaches::ApproachForm < Views::ApplicationView
  def initialize(approach:)
    @approach = approach
  end

  def view_template(&)
    form_with(model: @approach, id: dom_id(@approach, :form)) do |form|
      render_errors if @approach.errors.any?
      
      div do
        form.label :title
        form.text_field :title,
                                        class: input_classes(@approach.errors[:title])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@approach.errors[:description])
      end

      div do
        form.label :issue_id, "Issue"
        form.collection_select :issue_id, 
                               ::Issue.all, 
                               :id, 
                               :name,
                               { prompt: "Select a issue" },
                               { class: input_classes(@approach.errors[:issue_id]) }
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@approach.errors.count, 'error')} prohibited this approach from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @approach.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end

  def input_classes(errors)
    errors.any? ? "error" : ""
  end

  def checkbox_classes(errors)
    errors.any? ? "error" : ""
  end
end