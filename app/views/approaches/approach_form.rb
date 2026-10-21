class Views::Approaches::ApproachForm < Views::ApplicationView
  def initialize(approach:)
    @approach = approach
  end

  def view_template(&)
    form_with(model: @approach, id: dom_id(@approach, :form)) do |form|
      FormErrors(record: @approach)
      
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

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end