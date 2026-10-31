require "rails_helper"

RSpec.describe "Ordered voter content", type: :model do
  let(:voter) { create(:voter) }

  [ VoterLink, VoterStatement ].each do |model|
    context model.name do
      def content_attributes(model, index)
        model == VoterLink ? { label: "Community #{index}", url: "https://example.com/community/#{index}" } : { body: "Community priority #{index}" }
      end

      it "appends new items and keeps each voter's order separate" do
        first = model.create!(voter: voter, **content_attributes(model, 1))
        second = model.create!(voter: voter, **content_attributes(model, 2))
        other = model.create!(voter: create(:voter), **content_attributes(model, 3))

        expect([ first.position, second.position, other.position ]).to eq([ 1, 2, 1 ])
      end

      it "moves items in both directions, including inactive items" do
        items = 3.times.map { model.create!(voter: voter, **content_attributes(model, it)) }
        items[1].update!(active: false)
        items[2].move!("up")
        expect(model.where(voter: voter).ordered).to eq([ items[0], items[2], items[1] ])
        items[0].move!("down")
        expect(model.where(voter: voter).ordered).to eq([ items[2], items[0], items[1] ])
        expect(model.where(voter: voter).active.ordered).to eq([ items[2], items[0] ])
      end

      it "leaves the order unchanged when moving beyond an end" do
        first = model.create!(voter: voter, **content_attributes(model, 1))
        last = model.create!(voter: voter, **content_attributes(model, 2))
        first.move!("up")
        last.move!("down")

        expect(model.where(voter: voter).ordered).to eq([ first, last ])
      end

      it "removes the voter's content with their account" do
        model.create!(voter: voter, **content_attributes(model, 1))
        expect { voter.destroy! }.to change(model, :count).by(-1)
      end
    end
  end

  it "requires link labels and rejects non-web and malformed URLs" do
    [ "javascript:alert(1)", "data:text/html,hello", "file:///tmp/example", "https:///missing-host", "not a URL" ].each do |url|
      link = voter.voter_links.new(label: "Community guide", url: url)
      expect(link).not_to be_valid
      expect(link.errors[:url]).not_to be_empty
    end
    expect(voter.voter_links.new(label: " ", url: "https://example.com")).not_to be_valid
  end

  it "accepts HTTP and HTTPS links and trims surrounding whitespace" do
    [ "http://example.com", "https://example.com/guide?q=community#overview" ].each do |url|
      link = voter.voter_links.create!(label: " Community guide ", url: " #{url} ")
      expect(link).to have_attributes(label: "Community guide", url: url)
    end
  end

  it "requires nonblank statement text" do
    statement = voter.voter_statements.new(body: " \n ")
    expect(statement).not_to be_valid
    expect(statement.errors[:body]).to include("can't be blank")
  end
end
