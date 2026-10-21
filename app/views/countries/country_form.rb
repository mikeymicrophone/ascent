# frozen_string_literal: true

class Views::Countries::CountryForm < Views::ApplicationView
  def initialize(country:)
    @country = country
  end

  def view_template(&)
    form_with(model: @country, id: dom_id(@country, :form)) do |form|
      FormErrors(record: @country)
      
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

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end