class Views::OfficialCodes::OfficialCodeForm < Views::ApplicationView
  def initialize(official_code:)
    @official_code = official_code
  end

  def view_template(&)
    form_with(model: @official_code, id: dom_id(@official_code, :form)) do |form|
      render_errors if @official_code.errors.any?
      
      div do
        form.label :policy_id, "Policy"
        form.collection_select :policy_id, 
                               ::Policy.all, 
                               :id, 
                               :name,
                               { prompt: "Select a policy" },
                               { class: input_classes(@official_code.errors[:policy_id]) }
      end

      div do
        form.label :code_number
        form.text_field :code_number,
                                        class: input_classes(@official_code.errors[:code_number])
      end

      div do
        form.label :title
        form.text_field :title,
                                        class: input_classes(@official_code.errors[:title])
      end

      div do
        form.label :full_text
        form.textarea :full_text,
                                        rows: 4,
                                        class: input_classes(@official_code.errors[:full_text])
      end

      div do
        form.label :summary
        form.textarea :summary,
                                        rows: 4,
                                        class: input_classes(@official_code.errors[:summary])
      end

      div do
        form.label :enforcement_mechanism
        form.textarea :enforcement_mechanism,
                                        rows: 4,
                                        class: input_classes(@official_code.errors[:enforcement_mechanism])
      end

      div do
        form.label :penalty_structure
        form.textarea :penalty_structure,
                                        rows: 4,
                                        class: input_classes(@official_code.errors[:penalty_structure])
      end

      div do
        form.label :effective_date
        form.date_field :effective_date,
                                        class: input_classes(@official_code.errors[:effective_date])
      end

      div do
        form.label :status
        form.text_field :status,
                                        class: input_classes(@official_code.errors[:status])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@official_code.errors.count, 'error')} prohibited this official_code from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @official_code.errors.each do |error|
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