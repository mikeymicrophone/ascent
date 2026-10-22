# frozen_string_literal: true

# Every resource form: the error summary, one labelled row per field, and the submit button.
#   class Views::Issues::IssueForm < Views::Components::Forms::Base
#     def view_template
#       row field(:title).text
#       row field(:topic_id).collection_select(::Topic.order(:title), text: :title, prompt: "Select a topic")
#     end
#   end
class Views::Components::Forms::Base < Superform::Rails::Form
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::Routes
  include Views::Components

  class Field < Superform::Rails::Field
    # A foreign key field also shows its association's errors, like "Topic must exist" on topic_id.
    def errors
      association = key.to_s.delete_suffix("_id")
      association == key.to_s ? super : super + object.errors[association]
    end

    def input(**attributes)
      super(**with_error_class(attributes))
    end

    def textarea(**attributes)
      super(**with_error_class(attributes))
    end

    def checkbox(**attributes)
      super(**with_error_class(attributes))
    end

    # datetime-local inputs only accept "2026-11-03T07:00", not Time#to_s.
    def datetime(**attributes)
      input(type: :"datetime-local", value: value&.strftime("%Y-%m-%dT%H:%M"), **attributes)
    end

    # Choose one of these records, shown by the given attribute.
    def collection_select(records, text:, prompt: nil, include_blank: nil, **attributes)
      choices = records.map { [ it.id, it.public_send(text) ] }
      Views::Components::Forms::Select.new(field, options: choices, blank: blank_text(prompt, include_blank), **with_error_class(attributes))
    end

    # Choose one of these [label, value] pairs, in the order Rails' select takes them.
    def select_choices(pairs, prompt: nil, include_blank: nil, **attributes)
      choices = pairs.map { |label, choice| [ choice, label ] }
      Views::Components::Forms::Select.new(field, options: choices, blank: blank_text(prompt, include_blank), **with_error_class(attributes))
    end

    private

    # A prompt only shows until something is chosen; a blank choice is always offered.
    def blank_text(prompt, include_blank)
      include_blank || (prompt if value.blank?)
    end

    def with_error_class(attributes)
      invalid? ? { class: "error" }.merge(attributes) : attributes
    end
  end

  def around_template(&)
    super do
      FormErrors(record: model)

      yield if block_given?

      div { submit class: "primary" }
    end
  end

  # A field's label above its control. Pass label: to say it differently from the attribute name.
  def row(component, label: nil)
    div do
      render label ? component.field.label { label } : component.field.label
      render component
    end
  end

  private

  def jurisdiction_choices
    ::Jurisdiction.includes(:jurisdictionable).map { [ jurisdiction_label(it), it.id ] }.sort
  end

  def jurisdiction_label(jurisdiction)
    "#{jurisdiction.name} (#{jurisdiction.jurisdictionable_type.titleize})"
  end

  def form_action
    @action ||= polymorphic_path(model)
  end

  def submit_value
    "#{resource_action.to_s.capitalize} #{model.model_name.human}"
  end
end
