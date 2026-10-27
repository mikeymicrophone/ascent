# frozen_string_literal: true

# A person's name with the surname carrying the weight; given and middle names stay light.
class Views::Components::PersonName < Views::ApplicationView
  prop :person, Person

  def view_template
    given = [ @person.first_name, @person.middle_name ].compact_blank.join(" ")
    span(class: "candidate-given") { "#{given} " } if given.present?
    strong(class: "candidate-surname") { @person.last_name }
  end
end
