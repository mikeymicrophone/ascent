# frozen_string_literal: true

# The list page for reference data without a page design of its own: the model's name as the heading, a
# row per record, and the pager, on the same IndexPage as every other list.
#   ResourceIndex(collection: @years, pagy: @pagy)
# The block draws each row, for a line about the record beside its name:
#   ResourceIndex(collection: @positions, pagy: @pagy) { |position| ListRow(record: position, title: position.title, meta: ...) }
# A list filtered to one parent names it in the heading and leads back to the whole list.
class Views::Components::ResourceIndex < Views::ApplicationView
  prop :collection, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(ActiveRecord::Base)
  prop :heading, _Nilable(String)
  prop :lede, _Nilable(String)

  def view_template(&row)
    IndexPage(title: @heading || default_heading, records: @collection, pagy: @pagy, noun: model_name.human.downcase,
      frame: "#{model_name.plural.dasherize}-list", eyebrow: "Reference", lede: @lede, trail: trail,
      empty_title: "No #{human_plural.downcase} yet", empty_text: "None has been added to Ascent.",
      actions: (method(:new_link) if scaffold_new_resource_visible?(model))) do |record|
      row ? row.call(record) : ListRow(record: record, title: record.name.to_s)
    end
  end

  private

  def model
    @collection.model
  end

  def model_name
    model.model_name
  end

  def human_plural
    model_name.human.pluralize
  end

  def default_heading
    @parent ? "#{human_plural} for #{@parent.name}" : human_plural
  end

  def trail
    @parent ? [ [ human_plural, polymorphic_path(model) ], [ @parent.name, @parent ] ] : []
  end

  def new_link
    PillLink(label: "New #{model_name.human.downcase}", path: new_polymorphic_path(model), icon: :plus)
  end
end
