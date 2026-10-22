# frozen_string_literal: true

# The page around a record's form: heading, the form, and links back.
#   ResourceFormPage(record: @issue) { render Views::Issues::IssueForm.new(@issue) }
class Views::Components::ResourceFormPage < Views::ApplicationView
  prop :record, ActiveRecord::Base

  def view_template
    div(class: "scaffold #{model_name.singular}-#{page}", id: dom_id(@record, page)) do
      h1 { heading }

      yield

      div do
        link_to "Show this #{model_name.human.downcase}", @record, class: "secondary" if @record.persisted?
        link_to "Back to #{model_name.human.downcase.pluralize}", polymorphic_path(@record.class), class: "secondary"
      end
    end
  end

  private

  def page
    @record.persisted? ? :edit : :new
  end

  def heading
    @record.persisted? ? "Editing #{model_name.human.downcase}" : "New #{model_name.human.downcase}"
  end

  def model_name
    @record.model_name
  end
end
