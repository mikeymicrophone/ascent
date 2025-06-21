require 'rails_helper'

RSpec.describe "approaches/show", type: :view do
  before(:each) do
    assign(:approach, Approach.create!(
      title: "Title",
      description: "MyText",
      issue: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
