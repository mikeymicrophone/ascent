require "rails_helper"

RSpec.describe Rule::Topic, type: :model do
  subject(:topic) { build(:rule_topic) }

  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to have_many(:statements).class_name("Rule::Statement").dependent(:destroy) }

  it "validates uniqueness of slug" do
    create(:rule_topic, slug: "use-of-force")

    duplicate = build(:rule_topic, slug: "use-of-force")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:slug]).to include("has already been taken")
  end
end
