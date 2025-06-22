class Views::Policies::PolicyForm < Views::ApplicationView
  def initialize(policy:)
    @policy = policy
  end

  def view_template(&)
    form_with(model: @policy, id: dom_id(@policy, :form)) do |form|
      render_errors if @policy.errors.any?
      
      div do
        form.label :governing_body_id, "Governing body"
        form.collection_select :governing_body_id, 
                               ::GoverningBody.all, 
                               :id, 
                               :name,
                               { prompt: "Select a governing body" },
                               { class: input_classes(@policy.errors[:governing_body_id]) }
      end

      div do
        form.label :area_of_concern_id, "Area of concern"
        form.collection_select :area_of_concern_id, 
                               ::AreaOfConcern.all, 
                               :id, 
                               :name,
                               { prompt: "Select a area of concern" },
                               { class: input_classes(@policy.errors[:area_of_concern_id]) }
      end

      div do
        form.label :approach_id, "Approach"
        form.collection_select :approach_id, 
                               ::Approach.all, 
                               :id, 
                               :name,
                               { prompt: "Select a approach" },
                               { class: input_classes(@policy.errors[:approach_id]) }
      end

      div do
        form.label :title
        form.text_field :title,
                                        class: input_classes(@policy.errors[:title])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@policy.errors[:description])
      end

      div do
        form.label :status
        form.text_field :status,
                                        class: input_classes(@policy.errors[:status])
      end

      div do
        form.label :enacted_date
        form.date_field :enacted_date,
                                        class: input_classes(@policy.errors[:enacted_date])
      end

      div do
        form.label :expiration_date
        form.date_field :expiration_date,
                                        class: input_classes(@policy.errors[:expiration_date])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@policy.errors.count, 'error')} prohibited this policy from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @policy.errors.each do |error|
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