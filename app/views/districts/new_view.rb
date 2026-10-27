class Views::Districts::NewView < Views::ApplicationView
  prop :district, District

  def view_template
    ResourceFormPage(record: @district) { render Views::Districts::DistrictForm.new(@district) }
  end
end
