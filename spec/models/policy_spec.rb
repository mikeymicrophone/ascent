require 'rails_helper'

RSpec.describe Policy, type: :model do
  it "stores its status as the word itself" do
    policy = create(:policy, status: "repealed")

    expect(policy.reload).to be_repealed
    expect(Policy.where(status: "repealed")).to contain_exactly(policy)
  end

  it "rejects an unknown status instead of raising" do
    policy = build(:policy, status: "active")

    expect(policy).not_to be_valid
    expect(policy.errors[:status]).to be_present
  end
end
