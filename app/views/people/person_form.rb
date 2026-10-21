class Views::People::PersonForm < Views::ApplicationView
  def initialize(person:)
    @person = person
  end

  def view_template(&)
    form_with(model: @person, id: dom_id(@person, :form)) do |form|
      FormErrors(record: @person)
      
      div do
        form.label :first_name
        form.text_field :first_name,
                                        class: input_classes(@person.errors[:first_name])
      end

      div do
        form.label :last_name
        form.text_field :last_name,
                                        class: input_classes(@person.errors[:last_name])
      end

      div do
        form.label :middle_name
        form.text_field :middle_name,
                                        class: input_classes(@person.errors[:middle_name])
      end

      div do
        form.label :email
        form.text_field :email,
                                        class: input_classes(@person.errors[:email])
      end

      div do
        form.label :birth_date
        form.date_field :birth_date,
                                        class: input_classes(@person.errors[:birth_date])
      end

      div do
        form.label :bio
        form.textarea :bio,
                                        rows: 4,
                                        class: input_classes(@person.errors[:bio])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end