# frozen_string_literal: true

# The page around a list of records: heading, new link, one block per record, and the pager.
#   ResourceIndex(collection: @issues, pagy: @pagy) { IssuePartial(issue: it) }
class Views::Components::ResourceIndex < Views::ApplicationView
  prop :collection, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template(&item_content)
    div(class: "scaffold #{plural}-index", id: "index_#{plural}") do
      div do
        h1 { model_name.human.pluralize }
        scaffold_new_resource_link "New #{model_name.human.downcase}", new_polymorphic_path(model), record: model
      end

      div(id: plural) do
        if @collection.any?
          @collection.each { list_item(it, &item_content) }
        else
          p { "No #{model_name.human.downcase.pluralize} found." }
        end
      end

      Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def list_item(record)
    div(id: dom_id(record, :list_item)) do
      yield record

      Ui::ResourceActions(resource: record)
    end
  end

  def model
    @collection.model
  end

  def model_name
    model.model_name
  end

  def plural
    model_name.plural
  end
end
