class Views::Elections::NewView < Views::ApplicationView
  prop :election, Election

  def view_template
    ResourceFormPage(record: @election) { render Views::Elections::ElectionForm.new(@election) }
  end
end
