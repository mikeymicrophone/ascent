class Views::Districts::DistrictForm < Views::ApplicationView
  def initialize(district:)
    @district = district
  end

  def view_template(&)
    form_with(model: @district, id: dom_id(@district, :form)) do |form|
      render_errors if @district.errors.any?
      
      div do
        form.label :name
        form.text_field :name,
                        class: input_classes(@district.errors[:name])
      end

      div do
        form.label :kind
        form.text_field :kind,
                        placeholder: "ward, legislative district, school district",
                        class: input_classes(@district.errors[:kind])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@district.errors.count, 'error')} prohibited this district from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @district.errors.each do |error|
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