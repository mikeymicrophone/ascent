class Views::Candidacies::CandidacyForm < Views::ApplicationView
  def initialize(candidacy:)
    @candidacy = candidacy
  end

  def view_template(&)
    form_with(model: @candidacy, id: dom_id(@candidacy, :form)) do |form|
      FormErrors(record: @candidacy)
      
      div do
        form.label :person_id, "Person"
        form.collection_select :person_id, 
                               ::Person.all, 
                               :id, 
                               :name,
                               { prompt: "Select a person" },
                               { class: input_classes(@candidacy.errors[:person_id]) }
      end

      div do
        form.label :race_id, "Race"
        form.collection_select :race_id, 
                               ::Race.with_naming_details, 
                               :id, 
                               :name,
                               { prompt: "Select a race" },
                               { class: input_classes(@candidacy.errors[:race_id]) }
      end

      div do
        form.label :status
        form.text_field :status,
                                        class: input_classes(@candidacy.errors[:status])
      end

      div do
        form.label :announcement_date
        form.date_field :announcement_date,
                                        class: input_classes(@candidacy.errors[:announcement_date])
      end

      div do
        form.label :participation
        form.select :participation,
                    [ [ "Active", "active" ], [ "Inactive", "inactive" ], [ "Off-ballot, approvable", "off_ballot" ] ],
                    {},
                    class: input_classes(@candidacy.errors[:participation])
      end

      div do
        form.label :platform_summary
        form.textarea :platform_summary,
                                        rows: 4,
                                        class: input_classes(@candidacy.errors[:platform_summary])
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