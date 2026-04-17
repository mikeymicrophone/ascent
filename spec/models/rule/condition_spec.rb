require "rails_helper"

RSpec.describe Rule::Condition, type: :model do
  subject(:condition) { build(:rule_condition) }

  it { is_expected.to belong_to(:statement).class_name("Rule::Statement") }
  it { is_expected.to have_many(:source_links).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_presence_of(:label) }

  it "validates uniqueness of slug within a statement" do
    statement = create(:rule_statement)
    create(:rule_condition, statement:, slug: "imminence")

    duplicate = build(:rule_condition, statement:, slug: "imminence")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:slug]).to include("has already been taken")
  end
end
