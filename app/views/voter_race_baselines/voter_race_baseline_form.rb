class Views::VoterRaceBaselines::VoterRaceBaselineForm < Views::ApplicationView
  def initialize(voter_race_baseline:)
    @voter_race_baseline = voter_race_baseline
  end

  def view_template(&)
    form_with(model: @voter_race_baseline, id: dom_id(@voter_race_baseline, :form)) do |form|
      FormErrors(record: @voter_race_baseline)
      
      div do
        form.label :voter_id, "Voter"
        form.collection_select :voter_id, 
                               ::Voter.all, 
                               :id, 
                               :name,
                               { prompt: "Select a voter" },
                               { class: input_classes(@voter_race_baseline.errors[:voter_id]) }
      end

      div do
        form.label :race_id, "Race"
        form.collection_select :race_id, 
                               ::Race.with_naming_details, 
                               :id, 
                               :name,
                               { prompt: "Select a race" },
                               { class: input_classes(@voter_race_baseline.errors[:race_id]) }
      end

      div do
        form.label :baseline
        form.number_field :baseline,
                                        class: input_classes(@voter_race_baseline.errors[:baseline])
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