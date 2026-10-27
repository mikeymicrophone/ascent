class Views::Countries::ShowView < Views::ApplicationView
  prop :country, Country

  def view_template
    ResourceShow(record: @country) { CountryPartial(country: @country) }
  end
end
