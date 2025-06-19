class Views::States::StateForm < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    form_with(model: @state, id: dom_id(@state, :form)) do |form|
      render_errors if @state.errors.any?
      
      div do
        form.label :name
        form.text_field :name,
                        class: input_classes(@state.errors[:name])
      end

      div do
        form.label :code
        form.text_field :code,
                        class: input_classes(@state.errors[:code])
      end

      div do
        form.label :country_id, "Country"
        form.collection_select :country_id, 
                               Country.all, 
                               :id, 
                               :name,
                               { prompt: "Select a country" },
                               { class: input_classes(@state.errors[:country_id]) }
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@state.errors.count, 'error')} prohibited this state from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @state.errors.each do |error|
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