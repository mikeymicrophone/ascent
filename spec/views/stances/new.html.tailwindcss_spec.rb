require 'rails_helper'

RSpec.describe "stances/new", type: :view do
  before(:each) do
    assign(:stance, Stance.new(
      candidacy: nil,
      issue: nil,
      approach: nil,
      explanation: "MyText",
      priority_level: "MyString",
      evidence_links: "MyText"
    ))
  end

  it "renders new stance form" do
    render

    assert_select "form[action=?][method=?]", stances_path, "post" do

      assert_select "input[name=?]", "stance[candidacy_id]"

      assert_select "input[name=?]", "stance[issue_id]"

      assert_select "input[name=?]", "stance[approach_id]"

      assert_select "textarea[name=?]", "stance[explanation]"

      assert_select "input[name=?]", "stance[priority_level]"

      assert_select "textarea[name=?]", "stance[evidence_links]"
    end
  end
end
