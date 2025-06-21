require 'rails_helper'

RSpec.describe "issues/index", type: :view do
  before(:each) do
    assign(:issues, [
      Issue.create!(
        title: "Title",
        description: "MyText",
        topic: nil
      ),
      Issue.create!(
        title: "Title",
        description: "MyText",
        topic: nil
      )
    ])
  end

  it "renders a list of issues" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
