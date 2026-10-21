class Views::Offices::OfficeForm < Views::ApplicationView
  def initialize(office:)
    @office = office
  end

  def view_template(&)
    form_with(model: @office, id: dom_id(@office, :form)) do |form|
      FormErrors(record: @office)
      
      div do
        form.label :position_id, "Position"
        form.collection_select :position_id, 
                               ::Position.all, 
                               :id, 
                               :title,
                               { prompt: "Select a position" },
                               { class: input_classes(@office.errors[:position_id]) }
      end

      div do
        form.label :jurisdiction_id, "Jurisdiction"
        form.select :jurisdiction_id,
                    jurisdiction_choices,
                    { prompt: "Select a jurisdiction" },
                    class: input_classes(@office.errors[:jurisdiction_id])
      end

      div do
        form.label :governing_body_id, "Governing body"
        form.collection_select :governing_body_id,
                               ::GoverningBody.order(:name),
                               :id,
                               :name,
                               { include_blank: "None" },
                               { class: input_classes(@office.errors[:governing_body_id]) }
      end

      div do
        form.label :chamber_id, "Chamber"
        form.collection_select :chamber_id,
                               ::Chamber.order(:name),
                               :id,
                               :name,
                               { include_blank: "None" },
                               { class: input_classes(@office.errors[:chamber_id]) }
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

  def input_classes(errors)
    errors.any? ? "error" : ""
  end

  def checkbox_classes(errors)
    errors.any? ? "error" : ""
  end
end