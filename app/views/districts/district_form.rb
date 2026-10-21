class Views::Districts::DistrictForm < Views::ApplicationView
  def initialize(district:)
    @district = district
  end

  def view_template(&)
    form_with(model: @district, id: dom_id(@district, :form)) do |form|
      FormErrors(record: @district)
      
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

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end