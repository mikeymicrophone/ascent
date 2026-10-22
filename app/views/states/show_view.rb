class Views::States::ShowView < Views::ApplicationView
  prop :state, ::State

  def view_template
    ResourceShow(record: @state) { StatePartial(state: @state) }
  end
end
