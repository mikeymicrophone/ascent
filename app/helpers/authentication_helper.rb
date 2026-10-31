module AuthenticationHelper
  def auth_field(form, attribute, type: :text, label: nil, hint: nil, **options)
    errors = form.object.errors[attribute]
    id = "#{form.object_name}_#{attribute}"
    descriptions = []
    descriptions << "#{id}_hint" if hint
    descriptions << "#{id}_error" if errors.any?

    tag.div(class: "auth-field") do
      safe_join([
        form.label(attribute, label),
        form.public_send("#{type}_field", attribute, **options, class: "auth-input",
          aria: { invalid: errors.any?, describedby: descriptions.presence&.join(" ") }),
        (tag.p(hint, id: "#{id}_hint", class: "auth-hint") if hint),
        (tag.p(errors.to_sentence, id: "#{id}_error", class: "auth-field-error") if errors.any?)
      ].compact)
    end
  end
end
