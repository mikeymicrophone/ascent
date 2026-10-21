class Views::Years::YearForm < Views::ApplicationView
  def initialize(year:)
    @year = year
  end

  def view_template(&)
    form_with(model: @year, id: dom_id(@year, :form)) do |form|
      FormErrors(record: @year)
      
      div do
        form.label :year
        form.number_field :year,
                                        class: input_classes(@year.errors[:year])
      end

      div do
        form.label :is_even_year
        form.checkbox :is_even_year,
                                        class: checkbox_classes(@year.errors[:is_even_year])
      end

      div do
        form.label :is_presidential_year
        form.checkbox :is_presidential_year,
                                        class: checkbox_classes(@year.errors[:is_presidential_year])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@year.errors[:description])
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

  def checkbox_classes(errors)
    errors.any? ? "error" : ""
  end
end