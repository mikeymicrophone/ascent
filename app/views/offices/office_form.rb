class Views::Offices::OfficeForm < Views::ApplicationView
  def initialize(office:)
    @office = office
  end

  def view_template(&)
    form_with(model: @office, id: dom_id(@office, :form)) do |form|
      render_errors if @office.errors.any?
      
      div do
        form.label :position_id, "Position"
        form.collection_select :position_id, 
                               ::Position.all, 
                               :id, 
                               :name,
                               { prompt: "Select a position" },
                               { class: input_classes(@office.errors[:position_id]) }
      end

      div do
        form.label :jurisdiction_id, "Jurisdiction"
        form.collection_select :jurisdiction_id, 
                               ::Jurisdiction.all, 
                               :id, 
                               :name,
                               { prompt: "Select a jurisdiction" },
                               { class: input_classes(@office.errors[:jurisdiction_id]) }
      end

      div do
        form.label :is_active
        form.checkbox :is_active,
                                        class: checkbox_classes(@office.errors[:is_active])
      end

      div do
        form.label :notes
        form.textarea :notes,
                                        rows: 4,
                                        class: input_classes(@office.errors[:notes])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@office.errors.count, 'error')} prohibited this office from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @office.errors.each do |error|
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