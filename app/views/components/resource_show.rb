# frozen_string_literal: true

# The page around one record: heading, the record's content, and its actions.
#   ResourceShow(record: @year) { YearPartial(year: @year) }
class Views::Components::ResourceShow < Views::ApplicationView
  prop :record, ActiveRecord::Base
  prop :heading, _Nilable(String)

  def view_template
    div(class: "scaffold #{model_name.singular}-show", id: dom_id(@record, :show)) do
      h1 { @heading || "Showing #{model_name.human.downcase}" }

      yield

      ActionBar(record: @record) if @record.is_a?(Engageable)

      Ui::ResourceActions(resource: @record)
    end
  end

  private

  def model_name
    @record.model_name
  end
end
