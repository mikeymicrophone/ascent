# frozen_string_literal: true

# A select whose blank choice carries text ("Select a topic", "None") and submits an empty value.
class Views::Components::Forms::Select < Superform::Rails::Components::Select
  def initialize(field, blank: nil, **)
    super(field, **)
    @blank = blank
  end

  def options(*collection)
    option(value: "", selected: field.value.blank?) { @blank } if @blank
    super
  end
end
