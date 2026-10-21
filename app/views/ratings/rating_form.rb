class Views::Ratings::RatingForm < Views::ApplicationView
  def initialize(rating:)
    @rating = rating
  end

  def view_template(&)
    form_with(model: @rating, id: dom_id(@rating, :form)) do |form|
      FormErrors(record: @rating)
      
      div do
        form.label :voter_id, "Voter"
        form.collection_select :voter_id, 
                               ::Voter.all, 
                               :id, 
                               :name,
                               { prompt: "Select a voter" },
                               { class: input_classes(@rating.errors[:voter_id]) }
      end

      div do
        form.label :candidacy_id, "Candidacy"
        form.collection_select :candidacy_id, 
                               ::Candidacy.all, 
                               :id, 
                               :name,
                               { prompt: "Select a candidacy" },
                               { class: input_classes(@rating.errors[:candidacy_id]) }
      end

      div do
        form.label :rating
        form.number_field :rating,
                          class: input_classes(@rating.errors[:rating])
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