require 'rails_helper'

RSpec.describe "approaches/index", type: :view do
  before(:each) do
    assign(:approaches, [
      Approach.create!(
        title: "Title",
        description: "MyText",
        issue: nil
      ),
      Approach.create!(
        title: "Title",
        description: "MyText",
        issue: nil
      )
    ])
  end

  it "renders a list of approaches" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
