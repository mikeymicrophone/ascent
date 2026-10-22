class Views::States::EditView < Views::ApplicationView
  prop :state, ::State

  def view_template
    ResourceFormPage(record: @state) { render Views::States::StateForm.new(@state) }
  end
end
