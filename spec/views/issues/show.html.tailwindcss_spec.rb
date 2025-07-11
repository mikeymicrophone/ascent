require 'rails_helper'

RSpec.describe "issues/show", type: :view do
  before(:each) do
    assign(:issue, Issue.create!(
      title: "Title",
      description: "MyText",
      topic: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
