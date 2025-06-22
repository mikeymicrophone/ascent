require 'rails_helper'

RSpec.describe "stances/show", type: :view do
  before(:each) do
    assign(:stance, Stance.create!(
      candidacy: nil,
      issue: nil,
      approach: nil,
      explanation: "MyText",
      priority_level: "Priority Level",
      evidence_links: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Priority Level/)
    expect(rendered).to match(/MyText/)
  end
end
