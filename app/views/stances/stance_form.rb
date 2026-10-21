class Views::Stances::StanceForm < Views::ApplicationView
  def initialize(stance:)
    @stance = stance
  end

  def view_template(&)
    form_with(model: @stance, id: dom_id(@stance, :form)) do |form|
      FormErrors(record: @stance)
      
      div do
        form.label :candidacy_id, "Candidacy"
        form.collection_select :candidacy_id, 
                               ::Candidacy.all, 
                               :id, 
                               :name,
                               { prompt: "Select a candidacy" },
                               { class: input_classes(@stance.errors[:candidacy_id]) }
      end

      div do
        form.label :approach_id, "Approach"
        form.collection_select :approach_id, 
                               ::Approach.all, 
                               :id, 
                               :name,
                               { prompt: "Select a approach" },
                               { class: input_classes(@stance.errors[:approach_id]) }
      end

      div do
        form.label :explanation
        form.textarea :explanation,
                                        rows: 4,
                                        class: input_classes(@stance.errors[:explanation])
      end

      div do
        form.label :priority_level
        form.text_field :priority_level,
                                        class: input_classes(@stance.errors[:priority_level])
      end

      div do
        form.label :evidence_links
        form.textarea :evidence_links,
                                        rows: 4,
                                        class: input_classes(@stance.errors[:evidence_links])
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