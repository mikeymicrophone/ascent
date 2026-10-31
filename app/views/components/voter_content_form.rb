class Views::Components::VoterContentForm < Views::ApplicationView
  prop :item, ActiveRecord::Base

  def view_template
    key = @item.model_name.param_key
    prefix = "#{key}_#{@item.id || "new"}"
    form_with(model: @item, class: "influencer-content-form") do
      FormErrors(record: @item)
      if @item.is_a?(VoterLink)
        label(for: "#{prefix}_label", class: "form-label") { "Label" }
        input(type: "text", id: "#{prefix}_label", name: "#{key}[label]", value: @item.label, required: true, class: "text-input")
        label(for: "#{prefix}_url", class: "form-label") { "URL" }
        input(type: "url", id: "#{prefix}_url", name: "#{key}[url]", value: @item.url, required: true, class: "text-input")
      else
        label(for: "#{prefix}_body", class: "form-label") { "Statement" }
        textarea(id: "#{prefix}_body", name: "#{key}[body]", rows: 4, required: true, class: "text-input") { @item.body }
      end
      input(type: "hidden", name: "#{key}[active]", value: "0")
      label(class: "inline-flex items-center gap-2") do
        input(type: "checkbox", name: "#{key}[active]", value: "1", checked: @item.active?)
        plain "Active"
      end
      button(type: "submit", class: "primary") { "#{@item.persisted? ? "Save" : "Add"} #{@item.is_a?(VoterLink) ? "link" : "statement"}" }
    end
  end
end
