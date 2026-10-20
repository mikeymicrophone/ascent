class Views::Counties::CountyForm < Views::ApplicationView
  def initialize(county:)
    @county = county
  end

  def view_template(&)
    form_with(model: @county, id: dom_id(@county, :form)) do |form|
      render_errors if @county.errors.any?
      
      div do
        form.label :name
        form.text_field :name,
                        class: input_classes(@county.errors[:name])
      end

      div do
        form.label :state_id, "State"
        form.collection_select :state_id, 
                               ::State.all, 
                               :id, 
                               :name,
                               { prompt: "Select a state" },
                               { class: input_classes(@county.errors[:state_id]) }
      end

      div do
        form.label :code
        form.text_field :code,
                        class: input_classes(@county.errors[:code])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@county.errors.count, 'error')} prohibited this county from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @county.errors.each do |error|
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