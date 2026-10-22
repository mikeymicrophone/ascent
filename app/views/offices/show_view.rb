class Views::Offices::ShowView < Views::ApplicationView
  prop :office, Office

  def view_template
    ResourceShow(record: @office) { OfficePartial(office: @office) }
  end
end
