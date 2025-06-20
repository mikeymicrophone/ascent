class Views::Residences::ResidenceForm < Views::ApplicationView
  def initialize(residence:)
    @residence = residence
  end

  def view_template(&)
    form_with(model: @residence, id: dom_id(@residence, :form)) do |form|
      render_errors if @residence.errors.any?
      
      div do
        form.label :voter_id, "Voter"
        form.collection_select :voter_id, 
                               ::Voter.all, 
                               :id, 
                               :name,
                               { prompt: "Select a voter" },
                               { class: input_classes(@residence.errors[:voter_id]) }
      end

      div do
        form.hidden_field :jurisdiction_type, value: "City"
        form.label :jurisdiction_id, "Jurisdiction"
        form.collection_select :jurisdiction_id, 
                               ::City.all, 
                               :id, 
                               :name,
                               { prompt: "Select a jurisdiction" },
                               { class: input_classes(@residence.errors[:jurisdiction_id]) }
      end

      div do
        form.label :registered_at
        form.datetime_field :registered_at,
                            class: input_classes(@residence.errors[:registered_at])
      end

      div do
        form.label :status
        form.text_field :status,
                        class: input_classes(@residence.errors[:status])
      end

      div do
        form.label :notes
        form.textarea :notes,
                      rows: 4,
                      class: input_classes(@residence.errors[:notes])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@residence.errors.count, 'error')} prohibited this residence from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @residence.errors.each do |error|
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