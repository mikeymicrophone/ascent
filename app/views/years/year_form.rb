class Views::Years::YearForm < Views::ApplicationView
  def initialize(year:)
    @year = year
  end

  def view_template(&)
    form_with(model: @year, id: dom_id(@year, :form)) do |form|
      render_errors if @year.errors.any?
      
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

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@year.errors.count, 'error')} prohibited this year from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @year.errors.each do |error|
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