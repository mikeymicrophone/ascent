require 'rails_helper'

RSpec.describe "stances/index", type: :view do
  before(:each) do
    assign(:stances, [
      Stance.create!(
        candidacy: nil,
        issue: nil,
        approach: nil,
        explanation: "MyText",
        priority_level: "Priority Level",
        evidence_links: "MyText"
      ),
      Stance.create!(
        candidacy: nil,
        issue: nil,
        approach: nil,
        explanation: "MyText",
        priority_level: "Priority Level",
        evidence_links: "MyText"
      )
    ])
  end

  it "renders a list of stances" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Priority Level".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
