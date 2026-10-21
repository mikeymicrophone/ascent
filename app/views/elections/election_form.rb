class Views::Elections::ElectionForm < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    form_with(model: @election, id: dom_id(@election, :form)) do |form|
      FormErrors(record: @election)
      
      div do
        form.label :name
        form.text_field :name,
                        class: input_classes(@election.errors[:name])
      end

      div do
        form.label :jurisdiction_id, "Jurisdiction"
        form.select :jurisdiction_id,
                    jurisdiction_choices,
                    { prompt: "Select a jurisdiction" },
                    class: input_classes(@election.errors[:jurisdiction_id])
      end

      div do
        form.label :kind
        form.select :kind,
                    %w[primary general special runoff].map { [ it.capitalize, it ] },
                    { include_blank: "None" },
                    class: input_classes(@election.errors[:kind])
      end

      div do
        form.label :year_id, "Year"
        form.collection_select :year_id, 
                               ::Year.all, 
                               :id, 
                               :name,
                               { prompt: "Select a year" },
                               { class: input_classes(@election.errors[:year_id]) }
      end

      div do
        form.label :election_date
        form.date_field :election_date,
                                        class: input_classes(@election.errors[:election_date])
      end

      div do
        form.label :early_voting_starts_on
        form.date_field :early_voting_starts_on,
                        class: input_classes(@election.errors[:early_voting_starts_on])
      end

      div do
        form.label :early_voting_ends_on
        form.date_field :early_voting_ends_on,
                        class: input_classes(@election.errors[:early_voting_ends_on])
      end

      div do
        form.label :status
        form.text_field :status,
                                        class: input_classes(@election.errors[:status])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@election.errors[:description])
      end

      div do
        form.label :is_mock
        form.checkbox :is_mock,
                                        class: checkbox_classes(@election.errors[:is_mock])
      end

      div do
        form.label :is_historical
        form.checkbox :is_historical,
                                        class: checkbox_classes(@election.errors[:is_historical])
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