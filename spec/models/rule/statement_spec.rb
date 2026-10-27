require "rails_helper"

RSpec.describe Rule::Statement, type: :model do
  subject(:statement) { build(:rule_statement) }

  it { is_expected.to belong_to(:topic).class_name("Rule::Topic") }
  it { is_expected.to have_many(:conditions).class_name("Rule::Condition").dependent(:destroy) }
  it { is_expected.to have_many(:source_links).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:summary) }

  it "validates uniqueness of slug within a topic" do
    topic = create(:rule_topic)
    create(:rule_statement, topic:, slug: "self-defense")

    duplicate = build(:rule_statement, topic:, slug: "self-defense")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:slug]).to include("has already been taken")
  end
end
