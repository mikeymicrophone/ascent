# frozen_string_literal: true

class Views::Components::ProfilePortrait < Views::ApplicationView
  prop :person, Person

  def view_template
    figure(class: "profile-portrait") do
      if @person.portrait_url.present?
        img(src: @person.portrait_url, alt: "Portrait of #{@person.full_name}", class: "profile-portrait-image",
          width: 400, height: 500, decoding: "async", referrerpolicy: "no-referrer")
        if @person.portrait_credit.present? || @person.portrait_source_url.present?
          figcaption(class: "profile-portrait-credit") do
            if @person.portrait_source_url.present?
              a(href: @person.portrait_source_url, target: "_blank", rel: "noopener noreferrer") { @person.portrait_credit.presence || "Photo source" }
            else
              plain @person.portrait_credit
            end
          end
        end
      else
        div(class: "profile-portrait-placeholder", role: "img", aria: { label: "No portrait for #{@person.full_name}" }) do
          [ @person.first_name, @person.last_name ].compact_blank.map { it.first }.join
        end
      end
    end
  end
end
