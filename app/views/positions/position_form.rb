class Views::Positions::PositionForm < Views::ApplicationView
  def initialize(position:)
    @position = position
  end

  def view_template(&)
    form_with(model: @position, id: dom_id(@position, :form)) do |form|
      render_errors if @position.errors.any?
      
      div do
        form.label :title
        form.text_field :title,
                                        class: input_classes(@position.errors[:title])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@position.errors[:description])
      end

      div do
        form.label :is_executive
        form.checkbox :is_executive,
                                        class: checkbox_classes(@position.errors[:is_executive])
      end

      div do
        form.label :term_length_years
        form.number_field :term_length_years,
                                        class: input_classes(@position.errors[:term_length_years])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@position.errors.count, 'error')} prohibited this position from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @position.errors.each do |error|
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