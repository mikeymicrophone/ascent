class Views::OfficialCodes::ShowView < Views::ApplicationView
  prop :official_code, OfficialCode

  def view_template
    ResourceShow(record: @official_code) { OfficialCodePartial(official_code: @official_code) }
  end
end
