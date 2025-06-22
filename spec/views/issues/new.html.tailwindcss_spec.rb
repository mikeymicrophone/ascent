require 'rails_helper'

RSpec.describe "issues/new", type: :view do
  before(:each) do
    assign(:issue, Issue.new(
      title: "MyString",
      description: "MyText",
      topic: nil
    ))
  end

  it "renders new issue form" do
    render

    assert_select "form[action=?][method=?]", issues_path, "post" do

      assert_select "input[name=?]", "issue[title]"

      assert_select "textarea[name=?]", "issue[description]"

      assert_select "input[name=?]", "issue[topic_id]"
    end
  end
end
