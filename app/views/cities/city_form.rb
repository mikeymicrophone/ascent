class Views::Cities::CityForm < Views::ApplicationView
  def initialize(city:)
    @city = city
  end

  def view_template(&)
    form_with(model: @city, id: dom_id(@city, :form)) do |form|
      render_errors if @city.errors.any?
      
      div do
        form.label :name
        form.text_field :name,
                        class: input_classes(@city.errors[:name])
      end

      div do
        form.label :state_id, "State"
        form.collection_select :state_id, 
                               ::State.all, 
                               :id, 
                               :name,
                               { prompt: "Select a state" },
                               { class: input_classes(@city.errors[:state_id]) }
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@city.errors.count, 'error')} prohibited this city from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @city.errors.each do |error|
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