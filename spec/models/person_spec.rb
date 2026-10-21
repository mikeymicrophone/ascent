require 'rails_helper'

RSpec.describe Person, type: :model do
  describe "usernames" do
    it "accepts a provisional generated username" do
      expect(build(:person, username: "kuhn_dawn_ny_ad_7", username_status: "provisional")).to be_valid
    end

    it "requires a status once a username is issued" do
      person = build(:person, username: "kuhn_dawn_ny_ad_7", username_status: nil)

      expect(person).not_to be_valid
      expect(person.errors[:username_status]).to be_present
    end

    it "keeps usernames unique and limited to code-safe characters" do
      create(:person, username: "kuhn_dawn_ny_ad_7", username_status: "provisional")

      expect(build(:person, username: "kuhn_dawn_ny_ad_7", username_status: "provisional")).not_to be_valid
      expect(build(:person, username: "dawn.kuhn", username_status: "verified")).not_to be_valid
    end

    it "allows people without a username" do
      expect(build(:person, username: nil, username_status: nil)).to be_valid
    end
  end
end
