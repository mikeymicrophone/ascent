require 'rails_helper'

RSpec.describe "issues/edit", type: :view do
  let(:issue) {
    Issue.create!(
      title: "MyString",
      description: "MyText",
      topic: nil
    )
  }

  before(:each) do
    assign(:issue, issue)
  end

  it "renders the edit issue form" do
    render

    assert_select "form[action=?][method=?]", issue_path(issue), "post" do

      assert_select "input[name=?]", "issue[title]"

      assert_select "textarea[name=?]", "issue[description]"

      assert_select "input[name=?]", "issue[topic_id]"
    end
  end
end
