# frozen_string_literal: true

class Views::Countries::CountryForm < Views::ApplicationView
  def initialize(country:)
    @country = country
  end

  def view_template(&)
    form_with(model: @country, id: dom_id(@country, :form)) do |form|
      render_errors if @country.errors.any?
      
      div do
        form.label :name
        form.text_field :name,
                        class: input_classes(@country.errors[:name])
      end

      div do
        form.label :code
        form.text_field :code,
                        class: input_classes(@country.errors[:code])
      end

      div do
        form.label :description
        form.textarea :description,
                        rows: 4,
                        class: input_classes(@country.errors[:description])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@country.errors.count, 'error')} prohibited this country from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @country.errors.each do |error|
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