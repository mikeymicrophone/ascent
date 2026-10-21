class Views::GovernanceTypes::GovernanceTypeForm < Views::ApplicationView
  def initialize(governance_type:)
    @governance_type = governance_type
  end

  def view_template(&)
    form_with(model: @governance_type, id: dom_id(@governance_type, :form)) do |form|
      FormErrors(record: @governance_type)
      
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

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end