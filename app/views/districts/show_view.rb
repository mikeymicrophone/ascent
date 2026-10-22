class Views::Districts::ShowView < Views::ApplicationView
  prop :district, District

  def view_template
    ResourceShow(record: @district) { DistrictPartial(district: @district) }
  end
end
