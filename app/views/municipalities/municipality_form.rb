class Views::Municipalities::MunicipalityForm < Views::ApplicationView
  def initialize(municipality:)
    @municipality = municipality
  end

  def view_template(&)
    form_with(model: @municipality, id: dom_id(@municipality, :form)) do |form|
      FormErrors(record: @municipality)
      
      div do
        form.label :name
        form.text_field :name,
                        class: input_classes(@municipality.errors[:name])
      end

      div do
        form.label :state_id, "State"
        form.collection_select :state_id, 
                               ::State.all, 
                               :id, 
                               :name,
                               { prompt: "Select a state" },
                               { class: input_classes(@municipality.errors[:state_id]) }
      end

      div do
        form.label :county_id, "County"
        form.collection_select :county_id, 
                               ::County.order(:name), 
                               :id, 
                               :name,
                               { include_blank: "None" },
                               { class: input_classes(@municipality.errors[:county_id]) }
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