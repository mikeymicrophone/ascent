require 'rails_helper'

# The pager shows the first and last pages, the current page with its neighbours, and a gap wherever
# it skips pages, so 190 pages of races never become 190 links.
RSpec.describe Views::Components::Pagination, type: :view do
  def pages(count:, page:)
    described_class.new(pagy: Pagy::Offset.new(count: count, page: page, limit: 25)).send(:pages)
  end

  it "keeps a short list of pages whole" do
    expect(pages(count: 75, page: 2)).to eq([ 1, 2, 3 ])
  end

  it "folds the pages far from the current one into gaps" do
    expect(pages(count: 1_000, page: 7)).to eq([ 1, :gap, 6, 7, 8, :gap, 40 ])
  end

  it "skips the gap where the window already reaches an end" do
    expect(pages(count: 1_000, page: 1)).to eq([ 1, 2, :gap, 40 ])
    expect(pages(count: 1_000, page: 3)).to eq([ 1, 2, 3, 4, :gap, 40 ])
  end
end
