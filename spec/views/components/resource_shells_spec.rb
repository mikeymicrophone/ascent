require 'rails_helper'

# The shells declare their arguments with Literal props, so a view that passes
# the wrong kind of object fails when it builds the shell, not halfway through rendering.
RSpec.describe "Resource shell props", type: :view do
  it "requires a relation for an index, so it can name the page after the model" do
    expect { Views::Components::ResourceIndex.new(collection: Issue.all) }.not_to raise_error
    expect { Views::Components::ResourceIndex.new(collection: [ build(:issue) ]) }.to raise_error(Literal::TypeError)
  end

  it "accepts a pager or none" do
    expect { Views::Components::ResourceIndex.new(collection: Issue.all, pagy: nil) }.not_to raise_error
    expect { Views::Components::ResourceIndex.new(collection: Issue.all, pagy: 2) }.to raise_error(Literal::TypeError)
  end

  it "requires a record for a show page" do
    expect { Views::Components::ResourceShow.new(record: build(:topic)) }.not_to raise_error
    expect { Views::Components::ResourceShow.new(record: nil) }.to raise_error(Literal::TypeError)
  end

  it "checks the converted views' own props" do
    expect { Views::Issues::ShowView.new(issue: build(:topic)) }.to raise_error(Literal::TypeError)
  end
end
