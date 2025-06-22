class Views::GovernanceTypes::GovernanceTypeForm < Views::ApplicationView
  def initialize(governance_type:)
    @governance_type = governance_type
  end

  def view_template(&)
    form_with(model: @governance_type, id: dom_id(@governance_type, :form)) do |form|
      render_errors if @governance_type.errors.any?
      
      div do
        form.label :name
        form.text_field :name,
                                        class: input_classes(@governance_type.errors[:name])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@governance_type.errors[:description])
      end

      div do
        form.label :authority_level
        form.number_field :authority_level,
                                        class: input_classes(@governance_type.errors[:authority_level])
      end

      div do
        form.label :decision_making_process
        form.text_field :decision_making_process,
                                        class: input_classes(@governance_type.errors[:decision_making_process])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@governance_type.errors.count, 'error')} prohibited this governance_type from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @governance_type.errors.each do |error|
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