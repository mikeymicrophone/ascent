class Views::Issues::IssueForm < Views::ApplicationView
  def initialize(issue:)
    @issue = issue
  end

  def view_template(&)
    form_with(model: @issue, id: dom_id(@issue, :form)) do |form|
      FormErrors(record: @issue)
      
      div do
        form.label :title
        form.text_field :title,
                                        class: input_classes(@issue.errors[:title])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@issue.errors[:description])
      end

      div do
        form.label :topic_id, "Topic"
        form.collection_select :topic_id, 
                               ::Topic.all, 
                               :id, 
                               :name,
                               { prompt: "Select a topic" },
                               { class: input_classes(@issue.errors[:topic_id]) }
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end