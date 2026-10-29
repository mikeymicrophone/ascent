require "rails_helper"

RSpec.describe "County FIPS", type: :request do
  it "lets an admin edit FIPS through the county form" do
    sign_in create(:voter, admin: true)
    county = create(:county)
    get edit_county_path(county)
    form = Nokogiri::HTML(response.body)
    expect(form.at_css('input[name="county[fips]"]')).to be_present
    expect(form.css('input[name="county[code]"]')).to be_empty

    patch county_path(county), params: { county: { fips: "01001" } }
    expect(response).to redirect_to(county)
    expect(county.reload.fips).to eq("01001")

    patch county_path(county), params: { county: { fips: "1001" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(county.reload.fips).to eq("01001")
  end
end
