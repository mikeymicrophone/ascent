require "rails_helper"

RSpec.describe "Campaign communications" do
  describe StanceEvidence do
    it "keeps quotes short" do
      evidence = build(:stance_evidence, quote: "a" * (StanceEvidence::QUOTE_LIMIT + 1))

      expect(evidence).not_to be_valid
      expect(evidence.errors[:quote]).to be_present
    end

    it "shows a moment in a video as a timestamp" do
      expect(build(:stance_evidence, offset_seconds: 102).timestamp).to eq("1:42")
      expect(build(:stance_evidence, offset_seconds: 3725).timestamp).to eq("1:02:05")
    end

    it "cites a communication once per stance" do
      evidence = create(:stance_evidence)

      expect(build(:stance_evidence, stance: evidence.stance, communication: evidence.communication)).not_to be_valid
    end
  end

  describe Communication do
    it "requires a web address and a known kind" do
      expect(build(:communication, url: "example.com/video")).not_to be_valid
      expect(build(:communication, kind: "podcast")).not_to be_valid
    end

    it "can record a removed post that keeps its archived copy" do
      post = build(:communication, kind: "post", availability: "removed", archived_url: "https://web.archive.org/web/2026/https://example.com/post")

      expect(post).to be_valid
    end
  end

  describe Channel do
    it "identifies an account by platform and handle" do
      create(:channel, platform: "instagram", handle: "examplecampaign")

      expect(build(:channel, platform: "instagram", handle: "examplecampaign")).not_to be_valid
      expect(build(:channel, platform: "tiktok", handle: "examplecampaign")).to be_valid
    end
  end

  describe Stance do
    it "allows one stance per candidacy and approach" do
      stance = create(:stance)

      expect(build(:stance, candidacy: stance.candidacy, approach: stance.approach)).not_to be_valid
    end
  end
end
