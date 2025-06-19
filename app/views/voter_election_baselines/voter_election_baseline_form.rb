class Views::VoterElectionBaselines::VoterElectionBaselineForm < Views::ApplicationView
  def initialize(voter_election_baseline:)
    @voter_election_baseline = voter_election_baseline
  end

  def view_template(&)
    form_with(model: @voter_election_baseline, id: dom_id(@voter_election_baseline, :form)) do |form|
      render_errors if @voter_election_baseline.errors.any?
      
      div do
        form.label :voter_id, "Voter"
        form.collection_select :voter_id, 
                               ::Voter.all, 
                               :id, 
                               :name,
                               { prompt: "Select a voter" },
                               { class: input_classes(@voter_election_baseline.errors[:voter_id]) }
      end

      div do
        form.label :election_id, "Election"
        form.collection_select :election_id, 
                               ::Election.all, 
                               :id, 
                               :name,
                               { prompt: "Select a election" },
                               { class: input_classes(@voter_election_baseline.errors[:election_id]) }
      end

      div do
        form.label :baseline
        form.number_field :baseline,
                                        class: input_classes(@voter_election_baseline.errors[:baseline])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@voter_election_baseline.errors.count, 'error')} prohibited this voter_election_baseline from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @voter_election_baseline.errors.each do |error|
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