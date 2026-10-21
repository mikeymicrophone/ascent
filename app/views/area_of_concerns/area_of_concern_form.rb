class Views::AreaOfConcerns::AreaOfConcernForm < Views::ApplicationView
  def initialize(area_of_concern:)
    @area_of_concern = area_of_concern
  end

  def view_template(&)
    form_with(model: @area_of_concern, id: dom_id(@area_of_concern, :form)) do |form|
      FormErrors(record: @area_of_concern)
      
      div do
        form.label :name
        form.text_field :name,
                                        class: input_classes(@area_of_concern.errors[:name])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@area_of_concern.errors[:description])
      end

      div do
        form.label :policy_domain
        form.text_field :policy_domain,
                                        class: input_classes(@area_of_concern.errors[:policy_domain])
      end

      div do
        form.label :regulatory_scope
        form.text_field :regulatory_scope,
                                        class: input_classes(@area_of_concern.errors[:regulatory_scope])
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