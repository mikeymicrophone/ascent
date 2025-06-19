class Views::Registrations::RegistrationForm < Views::ApplicationView
  def initialize(registration:)
    @registration = registration
  end

  def view_template(&)
    form_with(model: @registration, id: dom_id(@registration, :form)) do |form|
      render_errors if @registration.errors.any?
      
      div do
        form.label :voter_id, "Voter"
        form.collection_select :voter_id, 
                               ::Voter.all, 
                               :id, 
                               :name,
                               { prompt: "Select a voter" },
                               { class: input_classes(@registration.errors[:voter_id]) }
      end

      div do
        form.label :jurisdiction_id, "Jurisdiction"
        form.collection_select :jurisdiction_id, 
                               ::Jurisdiction.all, 
                               :id, 
                               :name,
                               { prompt: "Select a jurisdiction" },
                               { class: input_classes(@registration.errors[:jurisdiction_id]) }
      end

      div do
        form.label :registered_at
        form.datetime_field :registered_at,
                                        class: input_classes(@registration.errors[:registered_at])
      end

      div do
        form.label :status
        form.text_field :status,
                                        class: input_classes(@registration.errors[:status])
      end

      div do
        form.label :notes
        form.textarea :notes,
                                        rows: 4,
                                        class: input_classes(@registration.errors[:notes])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@registration.errors.count, 'error')} prohibited this registration from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @registration.errors.each do |error|
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