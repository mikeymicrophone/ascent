class Views::Municipalities::IndexView < Views::ApplicationView
  prop :municipalities, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :filtered_state, _Nilable(::State)

  def view_template
    ResourceIndex(collection: @municipalities, pagy: @pagy, heading: heading, details: (method(:filter_info) if @filtered_state)) do
      MunicipalityPartial(municipality: it)
    end
  end

  private

  def heading
    @filtered_state ? "Municipalities in #{@filtered_state.name}" : "Municipalities"
  end

  def filter_info
    div(class: "filter-info") do
      span { "Showing municipalities in " }
      link_to @filtered_state.name, @filtered_state, class: "link state"
      span { " - " }
      link_to "View all municipalities", municipalities_path, class: "link view-all"
    end
  end
end
