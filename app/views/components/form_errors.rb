# frozen_string_literal: true

class Views::Components::FormErrors < Views::ApplicationView
  def initialize(record:)
    @record = record
  end

  def view_template
    return if @record.errors.none?

    div(id: "error_explanation", class: "form-errors", role: "alert") do
      h2 { heading }

      ul(class: "error-messages") do
        @record.errors.each { |error| li { error.full_message } }
      end
    end
  end

  private

  def heading
    "#{pluralize(@record.errors.count, 'error')} prohibited this #{@record.model_name.human.downcase} from being saved:"
  end
end
