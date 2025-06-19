class Views::Candidacies::CandidacyForm < Views::ApplicationView
  def initialize(candidacy:)
    @candidacy = candidacy
  end

  def view_template(&)
    form_with(model: @candidacy, id: dom_id(@candidacy, :form)) do |form|
      render_errors if @candidacy.errors.any?
      
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
        form.label :election_id, "Election"
        form.collection_select :election_id, 
                               ::Election.all, 
                               :id, 
                               :name,
                               { prompt: "Select a election" },
                               { class: input_classes(@candidacy.errors[:election_id]) }
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
        form.label :party_affiliation
        form.text_field :party_affiliation,
                                        class: input_classes(@candidacy.errors[:party_affiliation])
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

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@candidacy.errors.count, 'error')} prohibited this candidacy from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @candidacy.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end

  def input_classes(errors)
    errors.any? ? "error" : ""
  end

  def checkbox_classes(errors)
    errors.any? ? "error" : ""
  end
end