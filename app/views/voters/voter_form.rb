class Views::Voters::VoterForm < Views::ApplicationView
  def initialize(voter:)
    @voter = voter
  end

  def view_template(&)
    form_with(model: @voter, id: dom_id(@voter, :form)) do |form|
      FormErrors(record: @voter)
      
      div do
        form.label :first_name
        form.text_field :first_name,
                                        class: input_classes(@voter.errors[:first_name])
      end

      div do
        form.label :last_name
        form.text_field :last_name,
                                        class: input_classes(@voter.errors[:last_name])
      end

      div do
        form.label :birth_date
        form.date_field :birth_date,
                                        class: input_classes(@voter.errors[:birth_date])
      end

      div do
        form.label :is_verified
        form.checkbox :is_verified,
                                        class: checkbox_classes(@voter.errors[:is_verified])
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

  def checkbox_classes(errors)
    errors.any? ? "error" : ""
  end
end