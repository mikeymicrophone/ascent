require 'rails_helper'

RSpec.describe "approaches/new", type: :view do
  before(:each) do
    assign(:approach, Approach.new(
      title: "MyString",
      description: "MyText",
      issue: nil
    ))
  end

  it "renders new approach form" do
    render

    assert_select "form[action=?][method=?]", approaches_path, "post" do

      assert_select "input[name=?]", "approach[title]"

      assert_select "textarea[name=?]", "approach[description]"

      assert_select "input[name=?]", "approach[issue_id]"
    end
  end
end
