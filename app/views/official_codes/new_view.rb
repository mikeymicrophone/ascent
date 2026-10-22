class Views::OfficialCodes::NewView < Views::ApplicationView
  prop :official_code, OfficialCode

  def view_template
    ResourceFormPage(record: @official_code) { render Views::OfficialCodes::OfficialCodeForm.new(@official_code) }
  end
end
