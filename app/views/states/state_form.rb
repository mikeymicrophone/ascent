class Views::States::StateForm < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    form_with(model: @state, id: dom_id(@state, :form)) do |form|
      FormErrors(record: @state)
      
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

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end