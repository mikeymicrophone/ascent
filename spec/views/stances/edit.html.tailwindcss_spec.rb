require 'rails_helper'

RSpec.describe "stances/edit", type: :view do
  let(:stance) {
    Stance.create!(
      candidacy: nil,
      issue: nil,
      approach: nil,
      explanation: "MyText",
      priority_level: "MyString",
      evidence_links: "MyText"
    )
  }

  before(:each) do
    assign(:stance, stance)
  end

  it "renders the edit stance form" do
    render

    assert_select "form[action=?][method=?]", stance_path(stance), "post" do

      assert_select "input[name=?]", "stance[candidacy_id]"

      assert_select "input[name=?]", "stance[issue_id]"

      assert_select "input[name=?]", "stance[approach_id]"

      assert_select "textarea[name=?]", "stance[explanation]"

      assert_select "input[name=?]", "stance[priority_level]"

      assert_select "textarea[name=?]", "stance[evidence_links]"
    end
  end
end
