require 'rails_helper'

RSpec.describe "approaches/edit", type: :view do
  let(:approach) {
    Approach.create!(
      title: "MyString",
      description: "MyText",
      issue: nil
    )
  }

  before(:each) do
    assign(:approach, approach)
  end

  it "renders the edit approach form" do
    render

    assert_select "form[action=?][method=?]", approach_path(approach), "post" do

      assert_select "input[name=?]", "approach[title]"

      assert_select "textarea[name=?]", "approach[description]"

      assert_select "input[name=?]", "approach[issue_id]"
    end
  end
end
