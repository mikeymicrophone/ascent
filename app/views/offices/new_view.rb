class Views::Offices::NewView < Views::ApplicationView
  prop :office, Office

  def view_template
    ResourceFormPage(record: @office) { render Views::Offices::OfficeForm.new(@office) }
  end
end
