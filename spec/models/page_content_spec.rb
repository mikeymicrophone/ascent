# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageContent do
  describe ".load" do
    it "loads the approval voting page copy" do
      page = described_class.load("approval_voting")

      expect(page.fetch(:hero)).to include(:kicker, :title, :lead, :actions)
      expect(page.fetch(:sections)).to all(include(:type))
      expect(page.dig(:hero, :actions)).to all(include(:text, :path, :style))
    end

    it "loads the seed data FAQ copy" do
      page = described_class.load("faq")

      expect(page.fetch(:hero)).to include(:kicker, :title, :lead, :actions)
      expect(page.fetch(:sections)).to all(include(:type))
      expect(page.dig(:hero, :actions).first).to include(:text, :url, :style)
      expect(page.fetch(:sections).find { it[:type] == "code" }).to include(
        language: "yaml",
        filename: "playgrounds_once_per_decade.yml"
      )
    end
  end
end
