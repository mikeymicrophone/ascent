class Views::GoverningBodies::GoverningBodyForm < Views::ApplicationView
  def initialize(governing_body:)
    @governing_body = governing_body
  end

  def view_template(&)
    form_with(model: @governing_body, id: dom_id(@governing_body, :form)) do |form|
      render_errors if @governing_body.errors.any?
      
      div do
        form.label :name
        form.text_field :name,
                                        class: input_classes(@governing_body.errors[:name])
      end

      div do
        form.label :jurisdiction_type
        form.text_field :jurisdiction_type,
                                        class: input_classes(@governing_body.errors[:jurisdiction_type])
      end

      div do
        form.label :jurisdiction_id
        form.number_field :jurisdiction_id,
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

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@governing_body.errors.count, 'error')} prohibited this governing_body from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @governing_body.errors.each do |error|
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