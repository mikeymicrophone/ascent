class Views::People::PersonPartial < Views::ApplicationView
  def initialize(person:)
    @person = person
  end

  def view_template(&)
    div(id: dom_id(@person), class: "person-partial") do
      h3 { @person.first_name }
      div do
        span { "Last name:" }
        whitespace
        span { @person.last_name }
      end
      div do
        span { "Middle name:" }
        whitespace
        span { @person.middle_name }
      end
      div do
        span { "Email:" }
        whitespace
        span { @person.email }
      end
      div do
        span { "Birth date:" }
        whitespace
        span { @person.birth_date }
      end
      div do
        span { "Bio:" }
        whitespace
        div(class: "mt-1") { simple_format(@person.bio) }
      end
    end
  end
end