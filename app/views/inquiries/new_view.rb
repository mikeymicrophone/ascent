# frozen_string_literal: true

class Views::Inquiries::NewView < Views::ApplicationView
  prop :inquiry, Inquiry

  def view_template
    div(class: "index-page") do
      PageHeader(
        title: "Inquiries",
        eyebrow: "Contact",
        lede: "Send us a question, feature idea, election inquiry, or investment note."
      )

      section(class: "place-section", data: { controller: "inquiry-subject" }) do
        form_with(model: @inquiry, url: inquiries_path, class: "influencer-content-form") do
          FormErrors(record: @inquiry)

          label(for: "inquiry_email", class: "form-label") { "Email" }
          input(
            type: "email",
            id: "inquiry_email",
            name: "inquiry[email]",
            value: @inquiry.email,
            required: true,
            class: "text-input"
          )

          label(for: "inquiry_subject", class: "form-label") { "Subject" }
          div(class: "chip-list") do
            Inquiry::SUBJECT_TAGS.each do |tag_text|
              button(
                type: "button",
                class: "place-chip cursor-pointer",
                data: {
                  action: "click->inquiry-subject#select",
                  inquiry_subject_value_param: tag_text
                }
              ) { tag_text }
            end
          end
          input(
            type: "text",
            id: "inquiry_subject",
            name: "inquiry[subject]",
            value: @inquiry.subject,
            required: true,
            class: "text-input",
            data: { inquiry_subject_target: "input" }
          )

          label(for: "inquiry_message", class: "form-label") { "Message" }
          textarea(
            id: "inquiry_message",
            name: "inquiry[message]",
            rows: 6,
            required: true,
            class: "text-input"
          ) { @inquiry.message }

          button(type: "submit", class: "primary") { "Send inquiry" }
        end
      end
    end
  end
end
