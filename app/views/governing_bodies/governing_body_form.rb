class Views::GoverningBodies::GoverningBodyForm < Views::ApplicationView
  def initialize(governing_body:)
    @governing_body = governing_body
  end

  def view_template(&)
    form_with(model: @governing_body, id: dom_id(@governing_body, :form)) do |form|
      FormErrors(record: @governing_body)
      
      div do
        form.label :name
        form.text_field :name,
                                        class: input_classes(@governing_body.errors[:name])
      end

      div do
        form.label :jurisdiction_id, "Jurisdiction"
        form.select :jurisdiction_id,
                    jurisdiction_choices,
                    { prompt: "Select a jurisdiction" },
                    class: input_classes(@governing_body.errors[:jurisdiction_id])
      end

      div do
        form.label :governance_type_id, "Governance type"
        form.collection_select :governance_type_id, 
                               ::GovernanceType.all, 
                               :id, 
                               :name,
                               { prompt: "Select a governance type" },
                               { class: input_classes(@governing_body.errors[:governance_type_id]) }
      end

      div do
        form.label :branch
        form.select :branch,
                    GoverningBody.branches.keys.map { |branch| [ branch.titleize, branch ] },
                    { include_blank: "None" },
                    class: input_classes(@governing_body.errors[:branch])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@governing_body.errors[:description])
      end

      div do
        form.label :meeting_schedule
        form.text_field :meeting_schedule,
                                        class: input_classes(@governing_body.errors[:meeting_schedule])
      end

      div do
        form.label :is_active
        form.checkbox :is_active,
                                        class: checkbox_classes(@governing_body.errors[:is_active])
      end

      div do
        form.label :established_date
        form.date_field :established_date,
                                        class: input_classes(@governing_body.errors[:established_date])
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

  def checkbox_classes(errors)
    errors.any? ? "error" : ""
  end
end