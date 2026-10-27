class Views::Countries::NewView < Views::ApplicationView
  prop :country, Country

  def view_template
    ResourceFormPage(record: @country) { render Views::Countries::CountryForm.new(@country) }
  end
end
