class Views::Positions::PositionForm < Views::ApplicationView
  def initialize(position:)
    @position = position
  end

  def view_template(&)
    form_with(model: @position, id: dom_id(@position, :form)) do |form|
      FormErrors(record: @position)
      
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
        form.label :branch
        form.select :branch,
                    Position.branches.keys.map { |branch| [ branch.titleize, branch ] },
                    { include_blank: "None" },
                    class: input_classes(@position.errors[:branch])
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

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end