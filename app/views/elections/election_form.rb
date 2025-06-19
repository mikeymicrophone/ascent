class Views::Elections::ElectionForm < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    form_with(model: @election, id: dom_id(@election, :form)) do |form|
      render_errors if @election.errors.any?
      
      div do
        form.label :office_id, "Office"
        form.collection_select :office_id, 
                               ::Office.all, 
                               :id, 
                               :name,
                               { prompt: "Select a office" },
                               { class: input_classes(@election.errors[:office_id]) }
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

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@election.errors.count, 'error')} prohibited this election from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @election.errors.each do |error|
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