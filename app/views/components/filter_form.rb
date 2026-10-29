# frozen_string_literal: true

# A list's filters on one line: a search box, dropdowns, then Apply and Clear. Hidden fields carry
# whatever the list is already narrowed to, such as a tab or a parent record.
#   FilterForm(url: races_path, label: "Filter races", placeholder: "Office, election or candidate", values: @filters,
#     clear_path: races_path, selects: [ [ :state_id, "State", states.map { [ it.name, it.id ] }, "All states" ] ])
class Views::Components::FilterForm < Views::ApplicationView
  prop :url, String
  prop :label, String
  prop :placeholder, String
  prop :values, Hash
  prop :clear_path, String
  prop :selects, Array, default: -> { [] }
  prop :hidden, Hash, default: -> { {} }
  prop :submit_on_change, _Boolean, default: false

  def view_template
    form_with url: @url, method: :get, class: "filter-form", local: true, aria: { label: @label },
      data: { controller: ("form-submit" if @submit_on_change) } do |form|
      @hidden.compact_blank.each { |key, value| form.hidden_field key, value: value }
      div(class: "filter-field filter-field-search") do
        form.label :q, @placeholder, class: "visually-hidden"
        form.search_field :q, value: @values["q"], placeholder: @placeholder, class: "listing-search-input"
      end
      @selects.each { |field, label, options, blank| select_field(form, field, label, options, blank) }
      div(class: "filter-actions") do
        button(type: "submit", class: "pill-button") do
          icon(:list_filter)
          plain "Apply"
        end
        link_to "Clear", @clear_path, class: "pill-button pill-button-ghost"
      end
    end
  end

  private

  def select_field(form, field, label, options, blank)
    div(class: "filter-field") do
      form.label field, label, class: "visually-hidden"
      form.select field, options, { include_blank: blank, selected: @values[field.to_s] }, class: "filter-select",
        data: { action: ("change->form-submit#submit" if @submit_on_change) }
    end
  end
end
