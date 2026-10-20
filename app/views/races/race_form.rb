class Views::Races::RaceForm < Views::ApplicationView
  def initialize(race:)
    @race = race
  end

  def view_template(&)
    form_with(model: @race, id: dom_id(@race, :form)) do |form|
      render_errors if @race.errors.any?
      
      div do
        form.label :election_id, "Election"
        form.collection_select :election_id, 
                               ::Election.recent, 
                               :id, 
                               :name,
                               { prompt: "Select an election" },
                               { class: input_classes(@race.errors[:election_id]) }
      end

      div do
        form.label :office_id, "Office"
        form.collection_select :office_id, 
                               ::Office.includes(:position, jurisdiction: :jurisdictionable), 
                               :id, 
                               :name,
                               { prompt: "Select an office" },
                               { class: input_classes(@race.errors[:office_id]) }
      end

      div do
        form.label :status
        form.select :status,
                    %w[upcoming active completed cancelled].map { [ it.capitalize, it ] },
                    {},
                    class: input_classes(@race.errors[:status])
      end

      div do
        form.label :description
        form.textarea :description,
                      rows: 4,
                      class: input_classes(@race.errors[:description])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@race.errors.count, 'error')} prohibited this race from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @race.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end
